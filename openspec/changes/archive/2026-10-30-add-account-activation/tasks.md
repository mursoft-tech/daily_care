# Tasks

## 1. Contratos de dominio y datos

- [x] 1.1 Consultar Context7 con las versiones instaladas: go_router 18.1.1 para leer `state.uri.queryParameters` y Riverpod 3.4.3 para `AsyncNotifier`, una consulta por concepto; verificar que cada respuesta muestra la API vigente antes de escribir código
- [x] 1.2 Crear `AccountInvitation` en `lib/domain/models/` con `code`, `email`, `childName` y `roomName` inmutables, sin JSON; verificar con `test/domain/models/account_invitation_test.dart` (igualdad por campos y ausencia de dependencias de Flutter)
- [x] 1.3 Declarar `AccountActivationRepository` en `lib/domain/repositories/` con `loadInvitation(String code)` y `activate(...)` devolviendo `Result`, y crear el contrato del datasource en `lib/data/datasources/account_activation_data_source.dart`; verificar con `flutter analyze` que `domain` no importa `data`
- [x] 1.4 Implementar `DemoAccountActivationDataSource` (código `7K4P9`, `lucia.fernandez@gmail.com`, Mateo · Sala Soles) y `AccountActivationRepositoryImpl`, traduciendo ausencias a `null` y errores a `Failure` sin exponer detalles; verificar con `test/data/repositories/account_activation_repository_test.dart` (código válido, código inexistente y activación exitosa)
- [x] 1.5 Implementar `ActivateAccount` en `lib/domain/use_cases/` con `ActivationResult` sellado y el orden código → email → coincidencia → contraseña → consentimiento, mínimo 8 caracteres; verificar con `test/domain/use_cases/activate_account_test.dart` cubriendo los seis errores y el caso feliz
- [x] 1.6 Exponer `accountActivationRepositoryProvider` y `activateAccountUseCaseProvider` en `lib/app/providers.dart`; verificar que `test/app/providers_test.dart` sobrescribe el repositorio con un fake y el contenedor resuelve el caso de uso

## 2. Tema y localización

- [x] 2.1 Añadir a `AppColors` los tres colores del consentimiento (`#FBF1D6`, `#8A7234`, `#5FB97E`) bajo un comentario que cite `docs/templates/activar-cuenta.dc.html`; verificar con `flutter analyze` y que ningún widget de la pantalla declara colores literales
- [x] 2.2 Añadir a `lib/l10n/app_es.arb` el título, subtítulo, textos de la tarjeta de invitación (con placeholders de niño y sala), labels de campos, autorización de fotos, CTA, pie, estados de carga/error y los mensajes de validación; verificar con `flutter gen-l10n` sin errores y `flutter analyze`

## 3. Campo compartido y enlace del login

- [x] 3.1 Crear `AppTextField` en `lib/ui/core/widgets/` con label 12/w700/letter-spacing .7, borde 1.5 `#EADFD0`, radio 14, fill blanco y padding 14/16, aceptando controller, estilo, teclado, obscureText, errorText y key; verificar con un widget test que renderiza label, valor y mensaje de error
- [x] 3.2 Migrar los dos campos de `login_form.dart` a `AppTextField` conservando `login-email-input` y `login-password-input`; verificar que `test/ui/features/login/login_view_test.dart` sigue pasando sin cambios de expectativas
- [x] 3.3 Convertir el enlace "Activá tu cuenta" del login en un `AppLink` que navega a `AppRoutes.activateAccount` conservando `login-activate-account-link` y la semántica de enlace; verificar con un widget test nuevo que al tocarlo se muestra la pantalla de activación

## 4. Pantalla de activación

- [x] 4.1 Añadir `activateAccount = '/activar-cuenta'` a `AppRoutes` y la ruta pública en `app_router.dart` leyendo `state.uri.queryParameters['codigo']`; verificar con `test/app/router/app_router_test.dart` que `/activar-cuenta?codigo=7K4P9` resuelve la vista
- [x] 4.2 Construir el esqueleto de `ActivateAccountView` (página `#FBF4EC` centrada, max 440, padding 40/24, scroll y `SafeArea`) con encabezado (logo 58, título, subtítulo) y tarjeta de invitación (avatar azul, "Te invitaron a seguir a", "Mateo · Sala Soles"); verificar con widget test a 1200 y 400 px de ancho que las piezas del template están presentes
- [x] 4.3 Implementar `consent_checkbox.dart` desmarcado por defecto con caja 24×24 radio 8 `#5FB97E`, fondo `#FBF1D6`, texto `#8A7234` y `Semantics(checked:)`; verificar con widget test que arranca desmarcado, alterna al tocarlo y expone el estado accesible
- [x] 4.4 Implementar el formulario con los tres `AppTextField`, la autorización, el CTA en gradiente y el pie "¿Ya tenés cuenta? Iniciar sesión"; verificar con widget test que el CTA usa el gradiente `#F4977E → #EE8164` y que el pie navega a `/login`
- [x] 4.5 Implementar `ActivateAccountViewModel` como `AsyncNotifier` con carga de invitación, `retry()`, email precargado, `isSubmitting`, `errorType` y delegación al caso de uso; verificar con `test/ui/features/account_activation/activate_account_view_model_test.dart` (carga, error con reintento, submit válido y cada rechazo)
- [x] 4.6 Conectar estados en la vista: `AsyncLoading` con etiqueta accesible, `AsyncError` con mensaje genérico y reintento, y errores de validación inline en coral bajo el campo correspondiente; verificar con widget tests que cada mensaje aparece solo ante su fallo
- [x] 4.7 Navegar a `/` tras una activación aceptada y mantener la pantalla ante un rechazo; verificar con widget test que usa un repositorio fake y comprueba la ruta final

## 5. Limpieza y verificación integral

- [x] 5.1 Eliminar `lib/ui/features/login/views/login_placeholder_view.dart` y corregir `integration_test/logout_flow_test.dart` para esperar la pantalla de login actual; verificar con `flutter analyze` y la ejecución de esa prueba en el dispositivo disponible
- [x] 5.2 Añadir `integration_test/activate_account_flow_test.dart` que recorra login → `/activar-cuenta` → completar datos válidos → marcar autorización → feed; verificar su ejecución en el dispositivo disponible
- [x] 5.3 Ejecutar `flutter gen-l10n`, `flutter analyze` y `flutter test` sin fallos, y revisar que no queden textos literales de la pantalla fuera del ARB

## Workflow follow-up

- Archivar el cambio cuando la revisión del proyecto esté aprobada.
- Sincronizar la spec `auth` con el nuevo requisito de activación al archivar.