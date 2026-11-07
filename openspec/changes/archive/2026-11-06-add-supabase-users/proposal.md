# Proposal

## Why

El proyecto remoto de Supabase solo tiene `public.daycares`. Sin una tabla de usuarios no se puede representar al staff ni a las familias, ni vincular un perfil de dominio con `auth.users`, lo que bloquea la autenticación real y las futuras FKs de tenant (`posts`, `parent_children`, etc.). Hace falta el modelo base de usuarios y sus enums para poder probar el backend con un usuario staff.

## What Changes

- Crear los enums `user_role` (`staff`, `parent`, `admin`) y `user_status` (`pending`, `active`).
- Crear `public.users` como perfil de dominio vinculado a `auth.users` por `id` (mismo UUID, `ON DELETE CASCADE`), con `daycare_id`, `role`, `status`, `full_name`, `avatar_url`, preferencias de notificación y timestamps. No se duplican `email` ni credenciales.
- Añadir el índice único `(daycare_id, id)` para habilitar FKs compuestas de tenant en tablas futuras.
- Provisionar el perfil automáticamente con un trigger `AFTER INSERT` sobre `auth.users` (`SECURITY DEFINER`), leyendo `daycare_id`, `role` y `full_name` desde `raw_user_meta_data`; el alta falla si faltan datos obligatorios.
- Activar RLS en `public.users` sin policies y denegar `anon`/`authenticated`; el acceso queda solo para `service_role` (backend-only).
- Sembrar por migración un usuario staff demo con credenciales documentadas y un daycare estable para pruebas.

Fuera de alcance: políticas RLS para acceso directo desde la app, tablas de `children`/`posts`/`invitations`, cambios en el esquema local `db/` y cualquier código Flutter.

## Capabilities

### New Capabilities

- `user-accounts`: perfil de usuario ligado a Supabase Auth, roles y estados, aislamiento por daycare, provisión automática y acceso backend-only.

### Modified Capabilities

- Ninguna. `tenancy` sigue cubriendo solo `public.daycares`; el comportamiento nuevo se describe en `user-accounts`.

## Impact

- Base de datos remota Supabase (PostgreSQL 17.11): dos migraciones tracked (`create_users`, `seed_demo_staff`).
- `auth.users`: nuevo trigger `AFTER INSERT` y función `SECURITY DEFINER` en `public`.
- Roles de base de datos: `service_role` conserva el acceso; `anon` y `authenticated` quedan denegados.
- Sin cambios en el esquema local de `db/` (modelo de auth distinto) ni en la app Flutter.
