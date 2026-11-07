# Tasks

## 1. Enums y tabla `public.users`

- [x] 1.1 Redactar la migración `create_users` con los enums `user_role` y `user_status`, la tabla `public.users` y sus constraints, y aplicarla con `apply_migration`; verificar con `list_migrations` que quedó registrada y con `list_tables` que `public.users` existe con las columnas esperadas.
- [x] 1.2 Verificar por consulta de solo lectura el PK `id`, la FK a `daycares(id)`, el `NOT NULL` de `daycare_id`, la clave única `(daycare_id, id)`, los defaults (`status = active`, preferencias en `true`) y el límite de `full_name` de 1 a 120 caracteres.
- [x] 1.3 Asociar el trigger `users_set_updated_at` a la función existente `public.set_updated_at()` y verificar por consulta de solo lectura que el trigger aparece en `pg_trigger` para `public.users`.

## 2. Provisión automática y acceso backend-only

- [x] 2.1 Crear la función `SECURITY DEFINER` de provisión con `search_path = ''`, nombres calificados y `REVOKE EXECUTE FROM PUBLIC`, y el trigger `AFTER INSERT` sobre `auth.users`; verificar con `pg_get_functiondef` y `pg_get_triggerdef` que la definición y el evento son correctos.
- [x] 2.2 Activar RLS en `public.users` sin policies, revocar todos los privilegios a `anon` y `authenticated`, y otorgar `SELECT/INSERT/UPDATE/DELETE` a `service_role`; verificar `relrowsecurity`, que `pg_policies` no devuelve filas y que `role_table_grants` solo muestra `postgres` y `service_role`.
- [x] 2.3 Probar el alta fallida en una transacción con `ROLLBACK`: insertar en `auth.users` sin `daycare_id` y sin `full_name`, comprobar que cada caso lanza error y que no queda ninguna fila nueva en `auth.users` ni en `public.users`.

## 3. Usuario staff de demostración

- [x] 3.1 Redactar y aplicar la migración `seed_demo_staff` con UUID fijo, email confirmado, contraseña hasheada con `extensions.crypt`/`gen_salt('bf')`, metadatos de rol staff y fila en `auth.identities` usando `ON CONFLICT DO NOTHING`; verificar por consulta de solo lectura que `public.users` tiene el perfil staff con el mismo UUID y el daycare demo.
- [x] 3.2 Verificar el login real del staff con la clave publicable contra el endpoint de Auth; comprobar que devuelve una sesión con `access_token` y el email demo.
- [x] 3.3 Documentar en `docs/db/supabase-users.md` el contrato de `raw_user_meta_data`, el modelo de acceso backend-only, la credencial demo y el procedimiento de rollback; verificar que la credencial documentada coincide con la del seed.

## 4. Verificación de integración

- [x] 4.1 Consultar `GET /rest/v1/users` con la clave pública (`anon`) y con una sesión `authenticated`; verificar que ambas peticiones quedan denegadas y no devuelven filas.
- [x] 4.2 Ejecutar `get_advisors` y verificar que no aparecen advertencias de seguridad nuevas para `public.users` (RLS, grants o función `SECURITY DEFINER`).
- [x] 4.3 En una transacción con `ROLLBACK`, actualizar el `full_name` del staff y comprobar que `updated_at` avanza y `created_at` no cambia; después eliminar el usuario de `auth.users` y comprobar que su perfil desaparece por cascada.

## Workflow follow-up

- Archivar el cambio después de que la revisión del proyecto quede satisfecha.
- Verificar el resultado archivado y que las specs principales incluyen `user-accounts`.
