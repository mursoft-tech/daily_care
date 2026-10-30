# Proposal

## Why

El enlace "Activá tu cuenta" del login no tiene comportamiento: una familia invitada no puede crear su contraseña ni entrar a la app. El template `docs/templates/activar-cuenta.dc.html` ya define la pantalla completa, pero no existe ruta, no hay forma de llegar a ella y no hay ninguna capa que resuelva la invitación ni valide sus datos.

## What Changes

- Nueva ruta pública `/activar-cuenta` que renderiza la pantalla de activación fiel al template oficial: página centrada de 440 px sobre `#FBF4EC`, logo, tarjeta de invitación con avatar y "niño · sala", campos de código, email y contraseña, consentimiento de fotos, CTA en gradiente y enlace de vuelta al login.
- El enlace "Activá tu cuenta" del login navega a esa ruta con cursor de mano, teclado y semántica de enlace; conserva su key de test.
- Nueva capa de dominio y datos para invitaciones, sin API ni base de datos todavía: modelo de invitación, contrato de repositorio, caso de uso de activación con validaciones, datasource demo y repositorio que implementa el contrato. La UI no conoce la implementación.
- Consentimiento de fotos **desmarcado y obligatorio**: el diseño del template se conserva, pero la activación se bloquea si no se autoriza.
- Activación válida navega al feed (`/`), mismo destino que un login exitoso.
- El código de invitación se puede recibir por query param (`?codigo=`), con fallback al código demo para cuando se llega desde el login.
- Extracción de un campo de texto compartido entre login y activación para no duplicar el estilo del template.
- Limpieza asociada: se elimina la vista de login de "próximamente" que ya no se usa y se corrige la prueba de integración de logout, que todavía espera ese texto en `/login`.

## Capabilities

### New Capabilities

Ninguna. La activación pertenece al comportamiento de autenticación ya existente.

### Modified Capabilities

- `auth`: se añade el requisito de activación de cuenta por invitación, incluidos la pantalla fiel al template, las validaciones de código/email/contraseña, el consentimiento de fotos obligatorio y el destino tras activar.

## Impact

- **Rutas**: nueva entrada en `lib/app/router/app_routes.dart` y `app_router.dart`.
- **UI**: nueva feature en `lib/ui/features/account_activation/`; cambios en `lib/ui/features/login/widgets/login_form.dart`; nuevo widget compartido en `lib/ui/core/widgets/`.
- **Dominio y datos**: nuevos archivos en `lib/domain/models/`, `lib/domain/repositories/`, `lib/domain/use_cases/`, `lib/data/datasources/` y `lib/data/repositories/`; nuevo provider en `lib/app/providers.dart`.
- **Tema**: tres valores de color nuevos para el bloque de consentimiento en `lib/app/theme/app_colors.dart`.
- **l10n**: nuevas claves en `lib/l10n/app_es.arb`; se regeneran `app_localizations*.dart`.
- **Pruebas**: unit de caso de uso y repositorio, view model, widget de la pantalla, router, integración del flujo login → activación → feed, y corrección de `integration_test/logout_flow_test.dart`.
- **Dependencias**: ninguna nueva.