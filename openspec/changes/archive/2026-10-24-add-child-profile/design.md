# Design

## Context

La app es Flutter con capas `ui → domain`, `data → domain` y `Result<T>` como contrato de error. `/kids` ya carga los ocho niños de demostración desde `DemoKidsDataSource` y usa `AppShell` con `selectedIndex: 1`. El dominio actual de `Child` no tiene fechas, notas de alergia ni padres: solo un contador `linkedParents` y una etiqueta corta de alergia. No hay API ni persistencia; todo el contenido del perfil sale de datos de demostración. Ver `proposal.md` para la motivación y `specs/child-profile/spec.md` para el comportamiento exigido.

## Goals / Non-Goals

**Goals:**

- Modelar la ficha completa en dominio sin filtrar detalles de UI ni de datos.
- Navegar `/kids` → `/kids/:childId` → `/kids` con deep link directo.
- Calcular la edad desde la fecha de nacimiento con una fecha inyectable, para demos y tests deterministas.
- Conservar el texto y el filtro del buscador al volver de una ficha.
- Reproducir el layout y los colores de `perfil-nino.dc.html` en los tres anchos del shell.

**Non-Goals:**

- No se implementan las pantallas de edición, resumen del día ni vinculación de padres; sus acciones quedan como "Próximamente".
- No hay autenticación, API, base de datos, caché ni persistencia.
- No se cambia la lógica de filtrado; solo se sincroniza el texto del buscador con el filtro que ya persiste.
- No se renombra ni se reordena la navegación existente.

## Decisions

### 1. Modelo de dominio más rico y contador derivado

`Child` conserva `id`, `firstName`, `lastName`, `colorToken` y agrega `birthDate`, `room`, `enrolledAt`, `allergy` (nullable) y `guardians`. `linkedParents` pasa a ser un getter que devuelve `guardians.length`, de modo que listado y ficha no puedan contradecirse. `Guardian` es una entidad inmutable con `id`, `firstName`, `lastName`, `relationship` (`mother`, `father`, `guardian`), `status` (`active`, `invited`) y `colorToken`. `Allergy` es un value object inmutable con `label` y `notes`.

Se descartó mantener `linkedParents` como campo independiente: la ficha necesita la lista real y el template muestra un contador que incluye una invitación pendiente. Se acepta esa semántica (pendiente cuenta como vinculado) porque es la que ya usan el listado, sus tests y el template. Se descartó un modelo `ChildProfile` separado en dominio: duplicaría la identidad del niño y obligaría a mantener dos fuentes de verdad.

### 2. Edad calculada con reloj inyectable

`calculateAge(birthDate, today)` vive en `domain/use_cases/` y aplica años cumplidos (resta uno si el cumpleaños aún no llegó). `AppProviders` expone `todayProvider` como `Provider<DateTime Function()>` con `DateTime.now` por defecto. Los view models guardan la fecha de referencia al construir el estado y entregan la edad ya calculada a la UI.

Se descartó `ageYears` como campo: el template ya mostraba una contradicción entre "3 años" y "12 mar 2022". También se descartó que el widget llame a `DateTime.now()`: haría los tests dependientes del calendario. Las fechas de demostración se eligen para que hoy den las edades del template (por ejemplo, Mateo nace el 12 mar 2023 y no en 2022), y los tests sobreescriben `todayProvider` con una fecha fija.

### 3. Ruta plana y búsqueda por id

Se agrega `AppRoutes.childProfile = '/kids/:childId'` y `AppRoutes.childProfilePath(id)`; la ruta se registra como `GoRoute` de primer nivel, hermana de `/kids`, porque cada vista monta su propio `AppShell` y no hay un `ShellRoute` compartido. El builder lee `state.pathParameters['childId']` y lo pasa a la vista; un id vacío se trata como "no encontrado". Se descartó anidar la ruta bajo `/kids` con `ShellRoute`: cambiaría la arquitectura de navegación de toda la app para una sola pantalla.

El repositorio expone `loadChild(String id) -> Future<Result<Child?>>`. `KidsDataSource` agrega `fetchChild(id)` y la implementación demo busca en la misma lista que usa el listado. `Success(null)` representa "no encontrado" y se distingue de `Failure` (error de datos). Se descartó reutilizar el estado del listado: un deep link directo debe funcionar sin depender de que `/kids` se haya visitado, y a futuro `GET /children/:id` es el contrato natural.

### 4. View model del perfil y estados

`ChildProfileViewModel` es un `AsyncNotifier` con familia por `childId` (Riverpod 3: el argumento entra por constructor). Construye `ChildProfileState { Child? child; int? ageYears }`: `child == null` significa no encontrado, y `AsyncError` significa fallo de carga. La vista muestra progreso, error genérico con "Reintentar", o no encontrado con "Volver a Niños". La navegación del shell queda fuera del `AsyncValue`, igual que en `/kids`.

Se descartó lanzar una excepción de "no encontrado": obligaría a inspeccionar el tipo de error en la UI y mezclaría un resultado de negocio con un fallo técnico.

### 5. Composición visual y tokens

La vista sigue la estructura del template: enlace de volver, cabecera con avatar de 84 px, banner de alergias condicional, tarjeta de datos y columna derecha de 300 px con CTA oscuro "Resumen del día", tarjeta "PADRES VINCULADOS" y enlace punteado "Vincular". Se reutilizan `AppShell`, `AppLink`, `AppAvatar`, `AppIcon`, `AppTypography` y `DashedBox`. El contenido se limita a 820 px, con padding horizontal de 40 px (20 px bajo 600 px).

Se agregan a `AppColors` solo los tokens que faltan: fondo/ícono/título/cuerpo del banner de alergias, fondo del avatar azul de padre y colores semánticos de estado activo/pendiente (mismos hexadecimales del template). El mapeo privado `_avatarFor` de `child_card.dart` se extrae a un helper compartido de la feature `kids` para que tarjeta y perfil no dupliquen la paleta; los avatares de padres usan fondo sólido con inicial blanca, como el template.

Se agregan dos assets que no existen: `assets/icons/alert-triangle.svg` y `assets/icons/chevron-left.svg`. El CTA "Resumen del día" reutiliza `assets/icons/logo_sun.svg`, que ya tiene el sol del template.

### 6. Fechas localizadas

Se agrega `core/formatters/app_date_formatter.dart` con `formatBirthDate(date, locale)` (`d MMM y` → "12 mar 2023") y `formatMonthYear(date, locale)` (`MMM y` → "feb 2025"). Reciben el locale de `Localizations.localeOf(context).toLanguageTag()`; `initializeDateFormatting('es')` ya se ejecuta en `main.dart`. No se migra el formateo del feed en este cambio.

### 7. Layout adaptativo y acciones

Con `LayoutBuilder`, si el contenido mide al menos 640 px se usa `Row` (izquierda `Expanded`, derecha 300 px); si no, `Column` en el orden del template (datos y luego acciones/padres). El umbral cubre 300 + 26 de separación + 300 del template con margen. El shell decide sidebar/rail/drawer por su cuenta, así que 800 px de viewport ya dan dos columnas dentro del contenido.

"Volver a Niños" hace `context.go(AppRoutes.kids)`. "Editar", "Resumen del día" y "Vincular padre" usan `AppLink` sin `onTap`, que ya muestra "Próximamente" sin navegar. La tarjeta de `/kids` recibe un callback desde `KidsView` y navega con `AppRoutes.childProfilePath`; la tarjeta no conoce el router.

### 8. Localización y accesibilidad

Todas las cadenas nuevas van a `app_es.arb` con placeholders/plurales: título "Alergias y notas", labels de datos, "PADRES VINCULADOS", roles (Mamá/Papá/Tutor), estados (activa/activo, invitación enviada), badges ACTIVA/PENDIENTE, "Vincular un padre"/"Vincular otro padre", estados de carga/error/no encontrado y etiquetas accesibles. El estado activo concuerda en género con el rol. El avatar mantiene `Semantics` de imagen y la tarjeta enlaza con `AppLink` para teclado y lectores de pantalla.

### 9. Persistencia del buscador al volver

`KidsState.query` ya sobrevive porque el provider no se destruye al abrir la ficha; el problema es que `KidsSearchField` crea su `TextEditingController` vacío cuando la vista se reconstruye. `KidsView` pasa `state?.query ?? ''` al buscador, que hidrata su controller con ese valor y lo sincroniza en `didUpdateWidget` solo cuando difiere del texto actual. La sincronización programática no reemite `onChanged` para evitar bucles y mantener una única fuente de verdad en `KidsState`.

Se descartó limpiar el filtro al volver: perdería el trabajo de la maestra y obligaría a repetir la búsqueda. Se descartó mover el controller al view model: el texto de edición es estado de UI y el view model ya expone la consulta como parte de `KidsState`.

## Risks / Trade-offs

- **Demo con fechas fijas y edad cambiante** → los tests del listado y del perfil deben sobreescribir `todayProvider`; sin eso, las expectativas de edad se rompen con el calendario.
- **"Vinculado" incluye invitaciones pendientes** → se documenta en la spec y en el modelo; si más adelante se quiere distinguir, se separa el contador en activos y pendientes y se ajusta el listado.
- **Cambios de constructor de `Child` y `linkedParents`** → obligan a actualizar `DemoKidsDataSource`, las tarjetas, los tests de dominio y los repositorios en el mismo cambio; se compila y testea por capas.
- **Deep link con id inexistente** → se cubre con el estado "no encontrado" y su acción de volver, sin mostrar detalles internos.
- **Datos de salud ficticios** → no se loguean modelos ni se muestran errores crudos; los datos demo no son PHI real.
- **Ruta plana `/kids/:childId`** → si en el futuro se adopta un shell con `ShellRoute`, habrá que reagrupar las rutas; hoy evita reescribir la navegación.
- **Controller y estado del buscador desincronizados** → el controller se hidrata desde `KidsState.query` y solo se actualiza cuando el valor difiere, sin reemitir `onChanged`; los tests cubren volver con filtro, volver sin filtro y limpiar después de volver.
- **Tokens nuevos** → se limitan a los hexadecimales del template para no desviar la identidad visual existente.

## Migration Plan

No hay datos persistidos ni API que migrar. El cambio es en memoria y se despliega con la app. Rollback: revertir el change; `/kids` vuelve a mostrar "Próximamente" al tocar una tarjeta y las fichas dejan de resolverse. Los tests existentes que dependan del constructor anterior de `Child` se actualizan en el mismo cambio.

## Open Questions

Ninguna que afecte specs, enfoque o desglose de tareas. El texto exacto de los datos demo de cada niño se define en implementación respetando las edades y los estados del template.
