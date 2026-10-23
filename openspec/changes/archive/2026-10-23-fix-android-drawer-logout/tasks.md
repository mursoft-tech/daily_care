# Tasks

## 1. Diagnóstico del reporte

- [x] 1.1 Reproducir el flujo en el dispositivo o emulador Android afectado con `flutter run -d <device>` sobre el commit actual; registrar si el drawer se cierra al tocar el logout, si aparece "Próximamente" y si la app monta `/login`; verificar que el APK instalado es el recién compilado comparando la hora de instalación con la del build.
- [x] 1.2 Repetir el flujo en Chrome a 400 px de ancho; verificar que el logout del drawer y el de la barra superior navegan a la pantalla de login sin diferencias respecto de Android.

## 2. Botón de logout con área táctil de 48 dp

- [x] 2.1 Crear `lib/ui/core/widgets/app_logout_button.dart` con `Semantics(button: true, label: l10n.logoutLabel)`, `InkWell` de 48x48 y el cuadrado visible de 32x32 con el ícono actual; verificar con un widget test que el área interactiva mide al menos 48x48.
- [x] 2.2 Migrar el logout del panel (drawer y sidebar), de la barra superior y del avatar del rail a `AppLogoutButton`, conservando colores, radios y posición; verificar con `flutter test test/ui/core/widgets/app_navigation_panel_test.dart` y `test/ui/core/widgets/app_shell_test.dart`.
- [x] 2.3 Eliminar el `Tooltip` de la acción de logout y comprobar que la etiqueta accesible sigue expuesta; verificar con un widget test que el nodo semántico tiene label "Cerrar sesión" y que un toque de 600 ms (long press) activa la navegación igual que un toque corto.

## 3. Cierre del drawer antes de navegar

- [x] 3.1 Envolver `onLogout` del panel dentro del drawer para ejecutar `Scaffold.of(drawerContext).closeDrawer()` antes de invocar el callback; verificar con un widget test que tras el toque `ScaffoldState.isDrawerOpen` es `false` y `LoginPlaceholderView` está visible.
- [x] 3.2 Añadir al test del shell compacto un toque desplazado del centro (`tapAt` sobre `rect.topLeft + Offset(4, 4)`) dentro del área de 48 dp; verificar que navega a `/login` y que no queda drawer abierto.
- [x] 3.3 Ajustar el layout del bloque de cuenta para que el cuadrado de 32 dp quede centrado en el área de 48 dp sin mover los 16 dp de margen al borde; verificar visualmente en Chrome a 400 px contra la captura previa del drawer.

## 4. Integración y verificación manual

- [x] 4.1 Ampliar `integration_test/logout_flow_test.dart` con un toque desplazado sobre el logout del drawer y aserciones de login visible y drawer cerrado; verificar con `flutter test integration_test -d emulator-5554`.
- [x] 4.2 Ejecutar la matriz manual en Android (toque corto, toque en el borde del área y pulsación de 600 ms) y en Chrome (mouse y teclado), y registrar el resultado en el resumen del cambio; verificar que los tres casos llegan a `/login`.

## 5. Validación final

- [x] 5.1 Ejecutar `flutter gen-l10n`, `flutter analyze` y `flutter test` sin errores ni warnings nuevos; verificar además que `test/` mantiene el espejo de `lib/` para los archivos agregados.

## Workflow follow-up

- Archivar el cambio cuando la revisión esté aprobada, para que la delta actualice `openspec/specs/feed/spec.md`.
