# Tasks

## 1. Tokens y Localización

- [x] 1.1 Agregar las cadenas de texto del login (título, subtítulo, selector de roles, etiquetas de campos, placeholder, botón de acción, mensajes de error y enlace de activación) en `lib/l10n/app_es.arb` y verificar generando l10n con `flutter gen-l10n`.
- [x] 1.2 Incorporar en `lib/app/theme/app_colors.dart` los colores o constantes faltantes de la plantilla `login.dc.html` (fondo `#FBF4EC`, gradiente coral/naranja) y verificar compilación limpia con `flutter analyze`.

## 2. Lógica y Estado de Autenticación (MVVM)

- [x] 2.1 Definir el modelo de estado `LoginState` y el notifier `loginNotifierProvider` en `lib/ui/features/login/view_models/login_view_model.dart` para gestionar la selección de rol (`personal` vs `familia`), autocompletado de email, validación de formato y verificación de credenciales fijas (`admin`/`admin123`).
- [x] 2.2 Crear tests unitarios en `test/ui/features/login/login_view_model_test.dart` verificando la conmutación de rol, autocompletado y validación de credenciales con `flutter test test/ui/features/login/login_view_model_test.dart`.

## 3. Componentes Visuales y Vista Adaptativa

- [x] 3.1 Implementar el componente visual `LoginHeroPanel` / `LoginHeroBanner` con gradiente coral, círculos traslúcidos, logotipo y claim de marca, adaptado tanto para escritorio como para móvil.
- [x] 3.2 Implementar `LoginForm` con los botones de rol ("Personal" / "Familia"), campos de email y contraseña con bordes y tipografías fieles a la plantilla, botón de acción y enlaces secundarios.
- [x] 3.3 Ensamblar la pantalla `LoginView` en `lib/ui/features/login/views/login_view.dart` usando `LayoutBuilder` (modo 2 columnas en pantallas ≥ 768px y banner superior en < 768px), actualizando la ruta en `lib/app/router/app_router.dart`.
- [x] 3.4 Actualizar y expandir los tests de widgets en `test/ui/features/login/login_placeholder_view_test.dart` (o renombrar a `login_view_test.dart`) para validar la renderización responsiva, interacción con el formulario y redirección tras login exitoso ejecutando `flutter test test/ui/features/login/`.

## 4. Verificación e Integración

- [x] 4.1 Ejecutar `flutter analyze` para asegurar conformidad con las reglas de linting y la ausencia de imports legacy o errores.
- [x] 4.2 Ejecutar la suite completa de tests unitarios y de widgets con `flutter test` para comprobar que no existan regresiones.
