# Design

## Context

Ver `proposal.md` para la motivación. Estado relevante antes de planificar:

- `AppNavigationPanel` (`lib/ui/core/widgets/app_navigation_panel.dart`) dibuja el logout como `AppLink` con un `Container` de 32x32 dp: el `InkWell` mide exactamente 32x32 y el padding de 16 dp de la fila no responde.
- `AppLink` envuelve el `InkWell` en un `Tooltip`. El `Tooltip` registra un gesto de pulsación larga; si el dedo se mantiene más de ~500 ms, el reconocedor de long-press gana el arena y `onTap` nunca se dispara: se ve el tooltip y no ocurre nada.
- El drawer pasa `onLogout` directo al panel, así que la navegación depende de que `context.go('/login')` desmonte el `Scaffold` con el drawer abierto.
- Los tests (`app_navigation_panel_test.dart`, `home_view_test.dart`, integration test) tocan el centro del widget y solo comprueban que `LoginPlaceholderView` existe; no miden el área táctil ni verifican que el drawer haya dejado de estar abierto. Un drawer que tapara la pantalla destino pasaría igual.
- Reproducción: en `emulator-5554` con el APK archivado, tanto el logout del drawer como el del AppBar navegan; en Chrome no hay observaciones. El fallo reportado es específico del dispositivo Android del usuario y del build usado, y no se pudo reproducir con el binario actual.

## Goals / Non-Goals

**Goals:**

- Que la acción de logout se active con un toque normal en cualquier punto de un área de 48x48 dp, sin exigir precisión ni duración corta.
- Que el menú lateral desaparezca de forma determinista al salir, sin depender del ciclo de vida de la ruta.
- Dejar pruebas que fallen si el área táctil se reduce o si el drawer queda abierto tras la navegación.

**Non-Goals:**

- Cambiar el aspecto visual del bloque de cuenta o del drawer.
- Autenticación real, guard, persistencia o limpieza de credenciales.
- Diagnosticar el build exacto del reporte mediante telemetría; la verificación es manual y con pruebas reproducibles.

## Decisions

### 1. Widget único `AppLogoutButton`

Nuevo `lib/ui/core/widgets/app_logout_button.dart`, usado por drawer, barra superior, sidebar y rail:

```dart
Semantics(
  button: true,
  label: l10n.logoutLabel,
  child: InkWell(                      // 48x48
    onTap: onLogout,
    child: Center(
      child: Container(                // 32x32, misma estética actual
        decoration: BoxDecoration(color: AppColors.background, radius: 10),
        child: AppIcon('assets/icons/logout.svg', size: 16),
      ),
    ),
  ),
)
```

- El `InkWell` ocupa 48x48; el cuadrado visible sigue en 32x32 centrado. Sin cambios de color ni de radios.
- `Semantics(button: true, label: …)` reemplaza al `Tooltip` como nombre accesible. Se elimina el `Tooltip`: es el gesto que puede tragarse un toque lento y no aporta nada en Android.
- Alternativa descartada: mantener `AppLink` y agrandar el `Container`. Cambia el tamaño visual del cuadrado y sigue sujeto al `Tooltip`.

### 2. Cerrar el drawer antes de navegar

En `_CompactShell`, el panel recibe un `onLogout` que primero cierra el menú y después navega:

```dart
onLogout: () {
  Scaffold.of(drawerContext).closeDrawer();
  onLogout();
}
```

`Scaffold.of` ya está disponible por el `Builder` que envuelve al panel. El orden es deliberado: el cierre no depende de que la ruta destino desmonte el `Scaffold` y, si la navegación tardara un frame, el usuario no ve el menú sobre la pantalla nueva.

`AppShell` sigue recibiendo `onLogout` como callback y sin importar `go_router`; `HomeView` mantiene `() => context.go('/login')`.

### 3. Sin `Tooltip` en la acción de logout

- La etiqueta accesible sale de `Semantics`.
- Se pierde el tooltip al pasar el mouse en web; se acepta porque el icono es estándar y la etiqueta semántica cubre lectores de pantalla. En los demás enlaces de la app el `Tooltip` de `AppLink` no cambia.

### 4. Cobertura de regresión

- Widget test del botón: `tester.getSize` del área interactiva ≥ 48x48.
- Widget test del shell compacto: abrir drawer, tocar **desplazado del centro** dentro del área (`tapAt(rect.topLeft + Offset(4, 4))`), y comprobar `LoginPlaceholderView` visible **y** `ScaffoldState.isDrawerOpen == false`.
- Test del panel: el toque en el borde del botón invoca `onLogout` una vez.
- Integration test Android: mismo flujo con toque desplazado; en un emulador con barra de gestos.

### 5. Diagnóstico previo

La primera tarea reproduce el fallo con `flutter run` sobre el dispositivo afectado y registra: si el drawer se cierra al tocar, si aparece "Próximamente" y si el build incluye `/login`. Esa observación distingue entre build desactualizado, gesto largo y toque fuera del área; el cambio cubre los dos últimos y deja constancia del primero.

## Risks / Trade-offs

- **El cambio no corrige un build viejo** → la tarea de diagnóstico lo detecta y lo documenta; instalar el build nuevo es parte de la verificación.
- **Cerrar el drawer antes de navegar puede animar el cierre sobre la pantalla de login** → el drawer se desmonta al cambiar de ruta; si se percibe un parpadeo, se evalúa cerrar sin animación (`closeDrawer()` ya anima en ~250 ms y la ruta cambia en el mismo frame).
- **Perder el tooltip en web** → se acepta a cambio de eliminar el gesto que cancela el tap; la etiqueta semántica sigue presente.
- **El área de 48 dp cambia la alineación del bloque de cuenta** → el cuadrado visible queda centrado en 48 y el padding de la fila se ajusta para conservar los 16 dp al borde.
- **Tests de toque por coordenadas son frágiles** → se calculan desde el `Rect` del widget encontrado por key, no con píxeles fijos.

## Migration Plan

1. Reproducir y registrar el comportamiento en el dispositivo afectado.
2. Crear `AppLogoutButton` y migrar los cuatro puntos de uso.
3. Cerrar el drawer antes de navegar.
4. Añadir tests de widget e integración.
5. `flutter gen-l10n`, `flutter analyze`, `flutter test`, integration test en Android y verificación manual en Chrome.

Rollback: revertir el cambio; no hay datos ni migraciones. La app vuelve al comportamiento anterior de `AppLink` en el logout.

## Open Questions

Ninguna que bloquee. La causa exacta del reporte se confirma en la primera tarea; las mitigaciones cubren toque impreciso, pulsación larga y orden de cierre.
