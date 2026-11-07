# Usuarios en Supabase (backend-only)

Modelo remoto de `public.users` vinculado a Supabase Auth. Este documento describe el contrato que debe respetar el backend al crear usuarios.

## Migraciones aplicadas

| Migración | Contenido |
| --- | --- |
| `create_users` | Enums `user_role`/`user_status`, tabla `public.users`, trigger `updated_at`, función de provisión, RLS y grants |
| `restrict_user_provisioning_execute` | Revoca `EXECUTE` de `handle_new_auth_user()` a `public`, `anon` y `authenticated` |
| `seed_demo_staff` | Usuario staff demo en `auth.users` + `auth.identities`; el trigger crea el perfil |
| `fix_demo_staff_auth_tokens` | Rellena con cadena vacía los tokens de Auth que GoTrue espera no nulos |

## Modelo

`public.users` guarda solo datos de dominio. El email y las credenciales viven en `auth.users`.

```
auth.users
  id ---------------------------+
  email                         |  mismo UUID, sin duplicar
  encrypted_password            |
                                v
public.users
  id                     uuid PK, FK auth.users(id) ON DELETE CASCADE
  daycare_id             uuid NOT NULL, FK daycares(id) ON DELETE RESTRICT
  role                   user_role  (staff | parent | admin)
  status                 user_status (pending | active), default active
  full_name              text 1..120
  avatar_url             text NULL
  notify_on_post         boolean default true
  daily_summary_enabled  boolean default true
  created_at / updated_at
  UNIQUE (daycare_id, id)   -- destino de FKs compuestas de tenant
```

## Contrato de `raw_user_meta_data`

Todo alta en `auth.users` debe enviar estos metadatos; si faltan, el alta completa falla y no queda un usuario de Auth sin perfil.

| Clave | Obligatoria | Regla |
| --- | --- | --- |
| `daycare_id` | Sí | UUID de un daycare existente |
| `full_name` | Sí | 1–120 caracteres |
| `role` | No | `staff`, `parent` o `admin`; por defecto `parent` |

Ejemplo de metadatos:

```json
{
  "daycare_id": "11111111-1111-4111-8111-111111111111",
  "role": "staff",
  "full_name": "Staff Sala Soles"
}
```

## Acceso backend-only

- RLS activa en `public.users` sin policies.
- `anon` y `authenticated` no tienen grants sobre la tabla.
- Solo `service_role` puede leer y escribir; la app nunca consulta `public.users` directamente.
- `public.handle_new_auth_user()` solo la ejecuta el trigger y `service_role`.

## Usuario staff demo

| Campo | Valor |
| --- | --- |
| Email | `staff@sala-soles.test` |
| Contraseña | `SalaSoles123!` |
| UUID | `22222222-2222-4222-8222-222222222222` |
| Daycare | `11111111-1111-4111-8111-111111111111` |
| Rol | `staff` |

Es una credencial exclusiva de desarrollo. No reutilizar en producción y eliminarla antes de publicar.

## Rollback

Aplicar migraciones compensatorias en este orden:

```sql
-- 1. Eliminar el usuario demo (la cascada borra public.users)
delete from auth.identities where user_id = '22222222-2222-4222-8222-222222222222';
delete from auth.users where id = '22222222-2222-4222-8222-222222222222';

-- 2. Quitar la provisión automática
drop trigger if exists on_auth_user_created on auth.users;
drop function if exists public.handle_new_auth_user();

-- 3. Quitar la tabla y los enums
drop table if exists public.users;
drop type if exists public.user_status;
drop type if exists public.user_role;
```
