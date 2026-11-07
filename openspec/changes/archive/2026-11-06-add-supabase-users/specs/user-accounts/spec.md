# Spec Delta

## Purpose

Define el perfil de usuario de OpenDayCare vinculado a Supabase Auth: pertenencia a un daycare, roles y estados, provisión automática desde el alta de autenticación y acceso exclusivo del backend.

## ADDED Requirements

### Requirement: Perfil vinculado a Supabase Auth

El sistema SHALL persistir cada perfil de usuario en `public.users` usando el mismo UUID de `auth.users`, SHALL eliminar el perfil cuando se elimine el usuario de autenticación, y SHALL NOT duplicar el email ni las credenciales.

#### Scenario: Perfil creado con el UUID de autenticación

- **WHEN** se crea un usuario en `auth.users`
- **THEN** existe una fila en `public.users` con el mismo `id`

#### Scenario: Eliminación en cascada

- **WHEN** se elimina un usuario de `auth.users`
- **THEN** su fila en `public.users` se elimina también

#### Scenario: Sin email duplicado

- **WHEN** se consulta un perfil
- **THEN** el email solo reside en `auth.users` y no existe una columna de email en `public.users`

### Requirement: Roles y estados de usuario

El sistema SHALL restringir `role` a `staff`, `parent` o `admin`, y `status` a `pending` o `active`, con `active` como valor por defecto.

#### Scenario: Rol válido

- **WHEN** se inserta un usuario con rol `staff`, `parent` o `admin`
- **THEN** la fila se acepta

#### Scenario: Rol inválido

- **WHEN** se inserta un usuario con un rol fuera del conjunto permitido
- **THEN** la inserción se rechaza

#### Scenario: Estado por defecto

- **WHEN** se inserta un usuario sin especificar `status`
- **THEN** el usuario queda con estado `active`

#### Scenario: Estado inválido

- **WHEN** se inserta un usuario con un estado fuera de `pending` o `active`
- **THEN** la inserción se rechaza

### Requirement: Pertenencia a un único daycare

Cada usuario SHALL pertenecer a exactamente un daycare existente, y un daycare SHALL poder tener muchos usuarios.

#### Scenario: Usuario con daycare válido

- **WHEN** se inserta un usuario con un `daycare_id` existente
- **THEN** la fila se acepta y queda asociada a ese daycare

#### Scenario: Daycare inexistente

- **WHEN** se inserta un usuario con un `daycare_id` que no existe
- **THEN** la inserción se rechaza

#### Scenario: Varios usuarios en el mismo daycare

- **WHEN** se insertan dos usuarios con el mismo `daycare_id`
- **THEN** ambos se aceptan porque la relación es uno a muchos

#### Scenario: Sin daycare

- **WHEN** se inserta un usuario sin `daycare_id`
- **THEN** la inserción se rechaza

### Requirement: Datos del perfil

El sistema SHALL requerir un `full_name` de entre 1 y 120 caracteres, SHALL aceptar `avatar_url` nulo, y SHALL inicializar `notify_on_post` y `daily_summary_enabled` en `true`.

#### Scenario: Perfil completo

- **WHEN** se inserta un usuario con un `full_name` válido
- **THEN** la fila se acepta con `avatar_url` nulo por defecto y ambas preferencias de notificación activas

#### Scenario: Nombre vacío

- **WHEN** se inserta un usuario con `full_name` vacío
- **THEN** la inserción se rechaza

#### Scenario: Nombre demasiado largo

- **WHEN** se inserta un usuario con un `full_name` de más de 120 caracteres
- **THEN** la inserción se rechaza

### Requirement: Referencia de tenant para usuarios

El sistema SHALL exponer la combinación `(daycare_id, id)` como clave única, de modo que otras tablas puedan referenciar a un usuario y validar al mismo tiempo que pertenece al daycare esperado.

#### Scenario: Referencia del mismo tenant

- **WHEN** una tabla hija referencia a un usuario con su `daycare_id` real
- **THEN** la referencia se acepta

#### Scenario: Referencia cruzada entre tenants

- **WHEN** una tabla hija referencia a un usuario con un `daycare_id` distinto al del usuario
- **THEN** la referencia se rechaza por no existir la combinación `(daycare_id, id)`

### Requirement: Provisión automática del perfil

El sistema SHALL crear el perfil automáticamente al insertarse un usuario en `auth.users`, tomando `daycare_id`, `role` y `full_name` de los metadatos del alta, con `parent` como rol por defecto.

#### Scenario: Alta con metadatos completos

- **WHEN** se crea un usuario de autenticación con `daycare_id`, `role` y `full_name` en sus metadatos
- **THEN** el perfil se crea con esos valores y el alta de autenticación se completa

#### Scenario: Rol omitido

- **WHEN** se crea un usuario de autenticación sin `role` en sus metadatos
- **THEN** el perfil se crea con rol `parent`

#### Scenario: Falta el daycare

- **WHEN** se crea un usuario de autenticación sin `daycare_id` en sus metadatos
- **THEN** el alta falla y no queda un usuario de autenticación sin perfil

#### Scenario: Falta el nombre

- **WHEN** se crea un usuario de autenticación sin `full_name` en sus metadatos
- **THEN** el alta falla y no queda un usuario de autenticación sin perfil

#### Scenario: Daycare inexistente en los metadatos

- **WHEN** se crea un usuario de autenticación con un `daycare_id` que no existe
- **THEN** el alta falla y no queda un usuario de autenticación sin perfil

### Requirement: Acceso exclusivo del backend

El sistema SHALL habilitar row-level security en `public.users` sin policies, SHALL denegar `SELECT`, `INSERT`, `UPDATE` y `DELETE` a `anon` y `authenticated`, y SHALL permitir esas operaciones solo a `service_role`.

#### Scenario: Lectura anónima denegada

- **WHEN** una petición corre como `anon` y consulta `public.users`
- **THEN** la base de datos devuelve un error de permiso en lugar de filas

#### Scenario: Lectura autenticada denegada

- **WHEN** una petición con sesión corre como `authenticated` y consulta `public.users`
- **THEN** la base de datos devuelve un error de permiso en lugar de filas

#### Scenario: Escritura anónima o autenticada denegada

- **WHEN** una petición corre como `anon` o `authenticated` e intenta insertar, actualizar o eliminar usuarios
- **THEN** la base de datos devuelve un error de permiso

#### Scenario: Acceso del backend permitido

- **WHEN** la petición corre como `service_role`
- **THEN** puede consultar, insertar, actualizar y eliminar usuarios

### Requirement: Mantenimiento de la marca de actualización

El sistema SHALL actualizar `updated_at` en cada modificación de un usuario y SHALL preservar `created_at`.

#### Scenario: Actualización del perfil

- **WHEN** cambia el `full_name` de un usuario
- **THEN** `updated_at` aumenta y `created_at` no cambia

### Requirement: Usuario staff de demostración

El sistema SHALL sembrar, mediante una migración separada, un usuario staff con UUID estable, email confirmado y pertenencia al daycare demo, utilizable para pruebas del backend.

#### Scenario: Semilla aplicada en un proyecto limpio

- **WHEN** se aplican todas las migraciones sobre el proyecto remoto
- **THEN** existe exactamente un usuario staff para el daycare demo, con email confirmado y perfil en `public.users`

#### Scenario: Credenciales documentadas

- **WHEN** se revisa la documentación del cambio
- **THEN** el email y la contraseña demo del usuario staff están documentados para las pruebas
