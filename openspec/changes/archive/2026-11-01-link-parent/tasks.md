# Tasks

## 1. Domain and Data Layer

- [x] 1.1 Extender el contrato `KidsRepository` con el método `linkGuardian` y verificar que las interfaces compilan con `flutter analyze`.
- [x] 1.2 Implementar `linkGuardian` en el repositorio en memoria agregando el nuevo `Guardian` con estado `isActive: false` a la ficha del niño y escribir pruebas unitarias en `test/data/` verificando la mutación.
- [x] 1.3 Extender `Guardian` con `email` e `invitationCode`, actualizar los fixtures de demostración y verificar con `flutter test test/domain/` que los modelos y sus derivados compilan y pasan.
- [x] 1.4 Rechazar correos ya vinculados al mismo niño con `Failure(GuardianAlreadyLinkedFailure())` y verificar con pruebas en `test/data/repositories/kids_repository_test.dart` que el duplicado no se agrega y que un correo distinto sí.
- [x] 1.5 Implementar el caso de uso `GenerateInvitationCode` (5 caracteres sin ambigüedad, regenerando colisiones) y verificarlo con pruebas unitarias en `test/domain/use_cases/`.

## 2. Localization and Navigation

- [x] 2.1 Agregar las cadenas de texto necesarias en `lib/l10n/` para la pantalla de vincular padre (título, descripción, labels de formulario, opciones de parentesco, botón de envío y feedback) y compilar con `flutter gen-l10n`.
- [x] 2.2 Definir la ruta `AppRoutes.linkParent` y registrar el `GoRoute` `/kids/:childId/vincular-padre` en `lib/app/router/app_router.dart` verificando la resolución de parámetros.
- [x] 2.3 Actualizar `LinkedParentsCard` para que la acción "Vincular padre" / "Vincular otro padre" navegue a la nueva ruta en vez de mostrar el SnackBar de "Próximamente", verificando la navegación en widget tests.
- [x] 2.4 Agregar la clave `linkParentEmailAlreadyLinked` en `lib/l10n/app_es.arb` y verificar que `flutter gen-l10n` genera el getter correspondiente sin errores de análisis.

## 3. UI and ViewModel Implementation

- [x] 3.1 Implementar `LinkParentViewModel` (Riverpod `AsyncNotifier` o `Notifier`) para manejar la validación de formulario, generación/exhibición del código de invitación y el llamado a `linkGuardian`.
- [x] 3.2 Implementar la vista `LinkParentView` y sus componentes según la plantilla `vincular-padre.dc.html`, con contenedor centrado (`maxWidth: 480`), botón cerrar, banner informativo, campos de formulario, selector de parentesco y caja dashed de código.
- [x] 3.3 Conectar el botón "Enviar invitación" al ViewModel, mostrando feedback y navegando de vuelta a `/kids/:childId`, y verificar el flujo completo con widget tests en `test/ui/features/kids/views/link_parent_view_test.dart`.
- [x] 3.4 Reemplazar el código fijo `7K4P9` del ViewModel por el código generado por `GenerateInvitationCode` y verificar con una prueba que dos aperturas del formulario producen códigos distintos.
- [x] 3.5 Mapear `GuardianAlreadyLinkedFailure` al error del campo correo y verificar con un widget test que se muestra el mensaje localizado y no se navega ni se agrega el duplicado.
- [x] 3.6 Verificar con un widget test de dos vinculaciones sucesivas que la ficha lista a ambos tutores en estado "PENDIENTE", que la cantidad coincide y que la acción pasa a "Vincular otro padre".

## 4. Verification and Integration

- [x] 4.1 Ejecutar `flutter analyze` y `flutter test` verificando que todas las pruebas pasen sin advertencias ni regresiones.
- [x] 4.2 Ejecutar nuevamente `flutter analyze` y `flutter test` tras los cambios de modelo, código por invitación y duplicados, verificando que no hay regresiones.
