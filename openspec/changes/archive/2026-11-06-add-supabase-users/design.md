# Design

## Context

Ver `proposal.md` para la motivación. El estado relevante del remoto:

- PostgreSQL **17.11** (el `db/` local es PostgreSQL 18 con auth propio; no es el objetivo de este cambio).
- Solo existe `public.daycares` (1 fila demo, UUID `11111111-1111-4111-8111-111111111111`), con RLS activa, cero policies y grants únicamente para `postgres` y `service_role`.
- `public.set_updated_at()` ya existe con `search_path = ''`.
- No hay enums ni triggers propios sobre `auth.users`, y `auth.users` está vacío.
- El repositorio no tiene carpeta `supabase/`: el historial remoto vive en `supabase_migrations.schema_migrations` y se aplica con `apply_migration` del MCP.

Restricciones: todo cambio de esquema o datos va por migración tracked; nada de SQL suelto. No se toca la app Flutter ni el esquema local `db/`.

## Goals / Non-Goals

**Goals:**

- Modelo `public.users` ligado a Supabase Auth, con roles, estados y aislamiento por daycare.
- Provisión automática y consistente del perfil al crear el usuario de autenticación.
- Acceso backend-only verificable y usuario staff demo reproducible.

**Non-Goals:**

- Policies RLS para `anon`/`authenticated` (la app no accede directo).
- Tablas hijas (`children`, `posts`, `invitations`) y sus FKs compuestas.
- Sincronizar el esquema local `db/` con el remoto.
- Cambiar el login demo de Flutter para usar Supabase Auth.

## Decisions

### 1. Migraciones tracked, sin carpeta `supabase/`

- `create_users`: enums, tabla, índice, trigger, RLS y grants.
- `restrict_user_provisioning_execute`: corrección de privilegios de la función de provisión.
- `seed_demo_staff`: usuario de autenticación staff y su identidad; el trigger crea el perfil.
- `fix_demo_staff_auth_tokens`: corrección de los campos de token que GoTrue espera no nulos.

Alternativa descartada: inicializar `supabase/` local y usar `supabase db push`. Añade una fuente de verdad duplicada que el proyecto no tiene hoy; el remoto ya se versiona con `apply_migration`.

### 2. UUID con `gen_random_uuid()`

El remoto es PG17 y `uuidv7()` es de PG18. `daycares` ya usa `gen_random_uuid()`; se mantiene la coherencia.

### 3. Perfil derivado de `auth.users`, sin duplicar identidad

`public.users.id` es PK y FK a `auth.users(id)` con `ON DELETE CASCADE`. No hay columnas `email` ni credenciales.

Alternativas descartadas: tabla de auth propia (choca con Supabase) y columna `email` duplicada (riesgo de desincronización y PHI innecesaria).

### 4. Trigger de provisión fail-closed

`AFTER INSERT ON auth.users` ejecuta una función `SECURITY DEFINER` con `search_path = ''` y nombres calificados. Contrato de `raw_user_meta_data`:

| Clave | Obligatoria | Regla |
| --- | --- | --- |
| `daycare_id` | Sí | UUID de un daycare existente |
| `full_name` | Sí | 1–120 caracteres |
| `role` | No | `staff`/`parent`/`admin`; por defecto `parent` |

Si falta o es inválido un campo obligatorio, el alta completa falla y no queda un usuario de Auth huérfano. Alternativas descartadas: ignorar el error (perfiles ausentes) y asignar el daycare demo por defecto (fuga entre tenants).

La función se crea en `public` (donde vive la tabla destino) y se le revoca `EXECUTE` a `PUBLIC`, `anon` y `authenticated`, porque Supabase concede el privilegio explícitamente a esos roles además de a `PUBLIC`. Solo la invoca el trigger sobre `auth.users` y `service_role`.

### 5. Aislamiento por `daycare_id` con clave compuesta

`daycare_id` es `NOT NULL` y FK a `daycares(id) ON DELETE RESTRICT`. Se añade `UNIQUE (daycare_id, id)` como destino de FKs compuestas futuras, replicando el patrón del esquema local.

Alternativa descartada: solo `daycare_id` sin clave compuesta; obligaría a filtrar el tenant en cada tabla hija desde la aplicación.

### 6. Columnas del doc, adaptadas a Supabase

- `avatar_url` (doc) en lugar de `avatar_key` (local).
- `status` nace `active`; el estado previo al signup se modela en `invitations`.
- `notify_on_post` y `daily_summary_enabled` en `true`.
- `updated_at` se mantiene con `public.set_updated_at()`.

### 7. RLS backend-only + grants explícitos

RLS activa sin policies y `REVOKE ALL` de `anon`/`authenticated`; `GRANT` de `SELECT/INSERT/UPDATE/DELETE` a `service_role`. Es el mismo modelo verificado en `daycares` y evita depender solo de RLS.

### 8. Seed del staff con SQL versionado

En `seed_demo_staff`:

- UUID fijo `22222222-2222-4222-8222-222222222222`.
- `auth.users` con `aud/role = 'authenticated'`, email confirmado, `raw_app_meta_data` de proveedor email y `raw_user_meta_data` con `daycare_id`, `role: staff` y `full_name`.
- Contraseña `SalaSoles123!` hasheada con `extensions.crypt(..., extensions.gen_salt('bf'))`; nunca en claro.
- Fila en `auth.identities` con `provider = 'email'` para que el login funcione.
- `confirmed_at` no se inserta: es columna generada.

Alternativas descartadas: creación manual por dashboard (no reproducible) y Admin API (no es una migración; deja el estado fuera del historial).

## Risks / Trade-offs

- **Contraseña demo en el historial de migraciones** → es solo para desarrollo; se documenta y se elimina con una migración compensatoria antes de producción. Nunca reutilizar esa contraseña.
- **El trigger puede bloquear altas de Auth** → es intencional; el backend debe enviar siempre `daycare_id` y `full_name`. El mensaje de error debe indicar el campo faltante sin datos sensibles.
- **Dependencia de columnas internas de `auth`** → Supabase puede cambiarlas en upgrades; tras cada upgrade verificar el alta y el login del staff demo.
- **`SECURITY DEFINER` en `public`** → `REVOKE EXECUTE FROM PUBLIC`, `search_path = ''` y ejecutar `get_advisors` después de aplicar.
- **Backend-only impide leer el perfil desde el cliente** → decisión consciente; si más adelante la app necesita acceso directo, será otro cambio con policies.
- **Seed no idempotente si se ejecuta a mano** → las migraciones corren una sola vez; usar `ON CONFLICT DO NOTHING` en el seed para tolerar reejecuciones accidentales.
- **GoTrue falla con 500 si los tokens de `auth.users` son `NULL`** → el seed deja `confirmation_token`, `recovery_token`, `email_change` y `email_change_token_new` en cadena vacía mediante migración correctiva.

## Migration Plan

1. Aplicar `create_users` con `apply_migration`.
2. Aplicar `restrict_user_provisioning_execute` para dejar la función de provisión solo en `postgres`/`service_role`.
3. Aplicar `seed_demo_staff` con `apply_migration`; el trigger debe crear el perfil staff.
4. Aplicar `fix_demo_staff_auth_tokens` para que GoTrue pueda autenticar el usuario demo.
5. Verificar solo lectura: `list_migrations`, `list_tables`, `get_advisors`, consulta de unión `auth.users`/`public.users` y prueba de login con la clave publicable.
6. Rollback: migración compensatoria que elimina el usuario demo (la cascada borra `public.users`), luego el trigger y la función, la tabla y los enums, en ese orden.

## Open Questions

Ninguna que cambie el alcance o el diseño.
