# Design

## Context

Ver `proposal.md` para la motivación. El proyecto ya tiene el feed implementado con el patrón `entidad de dominio -> contrato de repositorio -> datasource demo -> repositorio -> ViewModel -> View`, un shell adaptativo que recibe `selectedIndex` y un router con `/`, `/login` y la ruta de error. La referencia visual es `docs/templates/ninos.dc.html` y los screenshots `docs/desing/ninos.png` y `ninos2.png`.

Restricciones del proyecto (`AGENTS.md`): Riverpod 3, `MaterialApp.router`, capas `app/core/domain/data/ui`, contratos de repositorio, `Result<T>`, localización en ARB, `ui/core` reutilizable y tests con `ProviderScope`/`ProviderContainer`.

La plantilla define la pantalla solo para escritorio. Los anchos compactos se resuelven con las convenciones ya usadas por el shell.

## Goals / Non-Goals

**Goals:**

- Reproducir la pantalla de niños con fidelidad en colores, tipografía, radios, sombras y jerarquía visual.
- Reutilizar el shell y los átomos existentes (`AppShell`, `AppAvatar`, `AppLink`, `AppIcon`) sin duplicar navegación.
- Mantener la misma separación de capas y el mismo patrón de estados que el feed.
- Entregar una navegación real feed <-> niños en los tres anchos.
- Cubrir búsqueda, badges y responsive con tests que no dependan de servicios reales.

**Non-Goals:**

- Alta de niño, perfil del niño, vinculación de padres y edición.
- Persistencia, API, autenticación y autorización.
- Cambiar el diseño del feed o migrar el shell a `StatefulShellRoute`.
- Internacionalización a otros idiomas.

## Decisions

### 1. Navegación mínima, sin refactor del shell

Se mantiene `AppShell` dentro de cada vista y se agrega `/kids` al router existente. Cada entrada de `AppDestination` incluye una ruta opcional; los destinos con ruta navegan con `context.go`, los que no la tienen conservan el aviso "Próximamente".

```text
GoRouter
+-- /      -> HomeView  + AppShell(selectedIndex: 0)
+-- /kids  -> KidsView  + AppShell(selectedIndex: 1)
+-- /login -> LoginPlaceholderView
+-- error  -> RouteErrorView
```

- Las rutas viven en un archivo de constantes (`lib/app/router/app_routes.dart`) para que router y shell no dupliquen strings.
- `AppShell` recibe el índice de la vista; no deriva el índice de la URL. Esto mantiene el widget usable en tests con `MaterialApp` sin router.
- En compacto, el menú lateral se cierra antes de navegar; con destinos sin ruta, se conserva la ruta actual.

Alternativa descartada: `StatefulShellRoute.indexedStack`. Aporta índice automático y conserva scroll, pero obliga a sacar el shell de `HomeView` y reescribir los tests de breakpoints. Se pospone hasta que existan Avisos y Mi cuenta.

Alternativa descartada: callbacks de navegación inyectados desde cada vista. Duplica cuatro callbacks por pantalla; con una ruta declarativa en el destino alcanza.

### 2. Modelo de dominio acotado al listado

`Child` es inmutable y sin dependencias de Flutter:

```text
id, firstName, lastName, ageYears, linkedParents, allergyLabel?, colorToken
fullName  -> "Mateo Fernández"
initial   -> "M"
```

- `ageYears` en lugar de fecha de nacimiento: la edad se muestra como "3 años" y el perfil queda fuera de alcance. Cuando llegue el perfil se agrega `birthDate` y un formateador de edad.
- `colorToken` en lugar de `Color`: el dominio no conoce Flutter, igual que `Post.childColorToken`.
- `allergyLabel` es dato de demostración ("MANÍ", "LACTOSA"), no clave de localización. El texto "VINCULAR" sí es UI y sale de ARB.
- La regla de badge es: alergia primero, luego "VINCULAR" cuando `linkedParents == 0`, y si no hay badge se muestra el chevron. La alergia gana porque es información de seguridad.

### 3. Datos y estado

Se replica el patrón del feed:

```text
domain/repositories/kids_repository.dart      loadChildren() -> Result<List<Child>>
data/datasources/kids_data_source.dart        contrato del datasource
data/datasources/local/demo_kids_data_source.dart   ocho niños del template
data/repositories/kids_repository_impl.dart   traduce excepciones a Failure
app/providers.dart                            datasource y repositorio
```

Los ocho niños son los del template: Mateo Fernández, Sofía Méndez, Benjamín Ruiz, Valentina Soto, Tomás Díaz, Emma Castro, Lucas Romero y Olivia Vega.

El ViewModel es `AsyncNotifier<KidsState>`, con `KidsState(all, query)` y `visible` calculado por un caso de uso puro:

```text
domain/use_cases/filter_children.dart
  filterChildren(children, query) -> List<Child>
```

- El caso de uso normaliza mayúsculas y tildes españolas (`á é í ó ú ü ñ`) antes de comparar, para que "sofia" encuentre "Sofía".
- `build()` carga desde el contrato; `search(query)` actualiza el estado sin volver a consultar el repositorio; `retry()` invalida el provider, igual que el feed.
- El ViewModel no formatea ni filtra en la vista: solo orquesta.
- Alternativa descartada: `TextEditingController` + filtro en `KidsView`. Mezcla lógica en la vista y complica los tests.
- Alternativa descartada: providers separados de query y lista filtrada. Más piezas para una sola pantalla y un único estado derivado.

### 4. Composición de la pantalla

`KidsView` envuelve el contenido en `AppShell(selectedIndex: 1)` y usa `SingleChildScrollView` + `LayoutBuilder` + `ConstrainedBox(maxWidth: 880)` + padding `34/40/80`, igual que el home.

```text
KidsView
+-- KidsHeader            GESTIÓN / Niños / Agregar niño
+-- KidsSearchField       contenedor surface, ícono, TextField
+-- KidsSectionHeader     SALA SOLES / total / divisor
+-- KidsGrid              Wrap de ChildCard
     +-- ChildCard         avatar + nombre + meta + badge/chevron
```

- La grilla usa `Wrap` con ancho de ítem `(ancho - 14) / 2` cuando el contenido mide 700 px o más; en caso contrario, un ítem por fila con ancho completo. `Wrap` evita un `GridView` anidado dentro del scroll y elimina el overflow horizontal.
- La cabecera mantiene título y botón en la misma fila desde 480 px de contenido; por debajo, el botón baja debajo del título.
- El total de la sección es la cantidad total de niños, no la filtrada, para que coincida con el template.
- La tarjeta mide 48 px de avatar, padding 16, radio 18, borde `#ECE0D0` y la sombra suave ya usada por el feed.
- El hover de la tarjeta se implementa con un `StatefulWidget` que anima una traslación de -2 px y el color del borde a `#F2A78E`; `AppLink` sigue aportando cursor, teclado y semántica de enlace.
- El estado vacío reemplaza la grilla con el mensaje localizado, conservando cabecera, buscador y sección.

### 5. Tokens de color y assets

Se agregan a `AppColors` los pares del template:

```text
avatarPinkBackground   #F4B8CC   avatarPinkForeground   #C44A7A
avatarGreenBackground  #B9DEC4   avatarGreenForeground  #3E8B62
avatarYellowBackground #F4DC8E   avatarYellowForeground #9A7B1E
avatarPurpleBackground #C9B6E8   avatarPurpleForeground #7B5FC0
allergyBackground      #FBD8CC   allergyForeground      #D9684A
linkParentBackground   #F9D2DE   linkParentForeground   #C56486
```

El mapeo `colorToken -> par de colores` queda privado en `child_card.dart`, como ya ocurre en `FeedPostCard`; no se agrega un `ThemeExtension` para una sola pantalla.

Se extraen del template dos SVG nuevos: `assets/icons/search.svg` y `assets/icons/chevron-right.svg`. `pubspec.yaml` ya declara la carpeta `assets/icons/`, así que no cambia.

### 6. Localización

Claves nuevas en `lib/l10n/app_es.arb`:

| Clave | Texto |
|---|---|
| `kidsEyebrow` | GESTIÓN |
| `kidsTitle` | Niños |
| `addChild` | Agregar niño |
| `searchChildHint` | Buscar niño… |
| `kidsRoomLabel` | SALA SOLES |
| `kidsCount` | `{count, plural, =1{1 niño} other{{count} niños}}` |
| `childAge` | `{years, plural, =1{1 año} other{{years} años}}` |
| `linkedParents` | `{count, plural, =0{sin padres vinculados} =1{1 padre vinculado} other{{count} padres vinculados}}` |
| `linkParentBadge` | VINCULAR |
| `noKidsResults` | No encontramos niños con ese nombre |
| `kidsError` | No se pudo cargar el listado de niños |
| `loadingKids` | Cargando niños |

Después de editar el ARB se ejecuta `flutter gen-l10n`; el archivo generado no se edita a mano.

### 7. Accesibilidad y seguridad

- El buscador tiene etiqueta semántica (`searchChildHint`) y acción de limpiar cuando hay texto.
- Cada tarjeta expone una etiqueta semántica con nombre, edad, vinculación y alergia, sin depender solo del color del avatar.
- Los badges combinan color y texto; la alergia nunca se comunica solo por color.
- No se registran nombres de niños, alergias ni datos de sesión en logs.
- Los datos demo no contienen información real de personas.

### 8. Tests

| Nivel | Archivo | Cobertura |
|---|---|---|
| Dominio | `test/domain/use_cases/filter_children_test.dart` | Mayúsculas, tildes, coincidencia parcial, sin resultados |
| Datos | `test/data/repositories/kids_repository_test.dart` | `Success` con ocho niños y `Failure` ante excepción |
| UI | `test/ui/features/kids/kids_view_test.dart` | Cabecera, ocho tarjetas, badges, búsqueda, estado vacío, loading, error y reintento |
| UI | `test/ui/features/kids/kids_view_test.dart` | Dos columnas en 1200 px y una columna sin overflow en 400 px |
| Router | `test/app/router/app_router_test.dart` | `/kids` resuelve la vista de niños |
| Shell | `test/ui/core/widgets/app_shell_test.dart` | "Niños" navega cuando hay router; "Avisos" conserva el aviso |
| Integración | `integration_test/kids_flow_test.dart` | Desde `/` tocar "Niños", ver el listado y volver al feed |

Los tests de `AppShell` que hoy esperan "Próximamente" al tocar "Niños" se actualizan para usar un destino aún no implementado o un router de prueba.

## Risks / Trade-offs

- **Tests existentes acoplados a "Próximamente" en Niños** -> Actualizar `app_shell_test` y `home_view_test` en el mismo cambio; agregar el caso de navegación a nivel router.
- **`AppShell` acoplado a `context.go`** -> Mantener las rutas en constantes y el índice inyectado; los tests sin router tocan solo destinos no implementados.
- **Tildes y ñ en la búsqueda** -> Normalización explícita con mapa de caracteres españoles y test unitario del caso de uso.
- **Dos columnas con textos largos** -> `Expanded` + `maxLines: 1` en nombre, `Flexible` en la meta y badge no flexible; el breakpoint de 700 px evita el apretujamiento.
- **Tarjetas de distinta altura en `Wrap`** -> Las filas se alinean arriba; la meta puede ocupar dos líneas sin romper el layout.
- **Scroll perdido al cambiar de ruta** -> Aceptado en esta etapa; se resuelve al migrar a `StatefulShellRoute`.
- **Datos demo tratados como PHI** -> Nombres y alergias son ficticios y no se envían a ningún servicio.

## Migration Plan

1. Agregar tokens de color, SVG de búsqueda/chevron y claves ARB; ejecutar `flutter gen-l10n`.
2. Crear `Child`, el contrato, el datasource demo, el repositorio y los providers.
3. Crear el caso de uso de filtrado y el ViewModel con estados de carga, error y búsqueda.
4. Implementar `KidsHeader`, `KidsSearchField`, `KidsSectionHeader`, `ChildCard` y `KidsView`.
5. Agregar `/kids` al router y rutas a `AppDestination`; ajustar la navegación del shell y el índice activo.
6. Actualizar tests existentes y agregar los nuevos; ejecutar `flutter analyze`, `flutter test` y `flutter gen-l10n`.

Rollback: revertir los archivos del cambio; no hay migraciones de datos ni backend. `/kids` desaparece y "Niños" vuelve al aviso "Próximamente".

## Open Questions

Ninguna que afecte el alcance: el alta y el perfil quedan explícitamente como placeholders, y el breakpoint de dos columnas se fija en 700 px de contenido.
