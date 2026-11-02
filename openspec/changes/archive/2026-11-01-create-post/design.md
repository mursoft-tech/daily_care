# Design

## Context

Ver `proposal.md` para la motivación y `specs/post-creation/spec.md` + `specs/feed/spec.md` para el contrato. El estado actual que condiciona el diseño:

- `ComposerBar` y `_NewPostButton` usan `AppLink` sin `onTap`; `AppLink` cae en "Próximamente".
- `FeedRepository`/`FeedDataSource` solo leen y `DemoFeedDataSource` es `const` con una lista `static const`.
- `Post` guarda datos desnormalizados (`childName`, `childInitial`, `childColorToken`, `timeLabel`) y `PostType` tiene solo 3 valores; no puede representar varios destinatarios.
- `PostTypeBadge` y `FeedPostCard` usan `switch` exhaustivos; `FeedColors` es un `ThemeExtension` con tres pares de colores.
- `KidsViewModel` ya expone los niños de la sala; `todayProvider` permite relojes deterministas en tests.
- El formulario de alta de niño (`NewChildForm` + `NewChildViewModel`) es el precedente de estado y validación.

## Goals / Non-Goals

**Goals:**

- Un flujo de publicación completo y testeable sobre datos en memoria, con la capa de dominio como único lugar de validación y construcción.
- Destinatarios múltiples representados en un único `Post`, manteniendo la tarjeta actual.
- Siete tipos con color y etiqueta consistentes entre el formulario y el feed.
- Reutilizar shell, avatares, campos y tokens existentes sin introducir dependencias.
- Dejar `createPost` como punto de reemplazo cuando exista API.

**Non-Goals:**

- Editar publicaciones, adjuntar imágenes reales, persistencia o autenticación.
- Crear una publicación por cada niño seleccionado: se crea un solo `Post` para todas las familias.
- Migrar el feed a un modelo con entidades relacionadas; `Post` solo suma la lista de nombres de destinatarios.
- Rediseñar el shell o los formularios existentes.

## Decisions

### 1. Ruta estática y shell

`AppRoutes.newPost = '/publicaciones/nueva'` con `GoRoute` propio y `CreatePostView` usando `AppShell(selectedIndex: 0)`. No colisiona con rutas dinámicas. El orden de declaración es indiferente, pero se mantiene junto al resto de rutas antes de `RouteErrorView.path`.

Alternativa descartada: modal o `extra` con estado, que rompe deep links y el template de pantalla completa.

### 2. Wiring de las entradas

- `ComposerBar` recibe `VoidCallback onTap` y lo pasa al `AppLink` externo; el ícono de cámara deja de ser un `AppLink` anidado y queda decorativo, como en el template (toda la barra es un solo enlace).
- `AppNavigationPanel` recibe `VoidCallback onNewPost`; `_NewPostButton` lo usa. `AppShell` cablea `context.go(AppRoutes.newPost)` y, en el drawer, cierra el panel antes de navegar.
- El fallback de `AppLink` a "Próximamente" se conserva para los destinos todavía no implementados.

Alternativa descartada: que `AppNavigationPanel` importe `go_router`; se mantiene sin dependencia del router, como `KidsHeader`.

### 3. Los siete tipos y sus colores

`PostType` pasa a `{ food, nap, activity, achievement, mood, photo, announcement }`. Se agregan tokens en `AppColors` y se extienden los pares de `FeedColors` (`copyWith` y `lerp` incluidos):

| Tipo | Etiqueta | Fondo | Texto |
|---|---|---|---|
| `food` | COMIDA | `#F7E7A6` | `#9A7B1E` |
| `nap` | SIESTA | `#E7DCF6` | `#7B5FC0` |
| `activity` | ACTIVIDAD | `#C7E7F1` | `#2E89A6` |
| `achievement` | LOGRO | `#CFEBD8` | `#3E9B6C` |
| `mood` | ÁNIMO | `#F9D2DE` | `#C56486` |
| `photo` | FOTO | `#FBD8CC` | `#D9684A` |
| `announcement` | ANUNCIO | `#CCD8F4` | `#4E72C8` |

El chip del formulario usa el mismo fondo pastel; el estado seleccionado se marca con borde de 2 px en `AppColors.textStrong` y un ícono de check, porque el template no define un estado de selección legible (Comida, Actividad y Anuncio aparecen sólidos a la vez).

En la tarjeta, el ícono de megáfono pasa a depender de `PostAudience.room` en lugar de `PostType.announcement`, para que una publicación de sala de cualquier tipo tenga un avatar con sentido.

Alternativa descartada: mapear los siete chips a tres tipos; rompe la semántica del feed.

### 4. Borrador, selección múltiple y caso de uso

```text
PostDraft
  childIds : List<String>   // vacía = toda la sala
  type     : PostType
  body     : String
```

`CreatePost` recibe `FeedRepository`, `KidsRepository` y `DateTime Function() today`, y devuelve un resultado sellado como `CreateChild`:

```text
PostCreated(Post)
PostRejected(List<PostDraftError>)   // bodyRequired, recipientRequired (defensivo)
PostFailed()                          // niño inexistente o fallo de datos
```

Reglas:

- La descripción se valida con `trim()` no vacío; el error se limpia al escribir.
- Con `childIds` vacía la publicación es para la sala; si tiene ids, se resuelve cada niño con `loadChild` y cualquier id inexistente o carga fallida produce `PostFailed`, sin crear una publicación parcial.
- La instantánea del primer niño va en `childName`, `childInitial` y `childColorToken`; `Post.recipientNames` conserva todos los nombres en el orden de selección.
- `Post` suma `recipientNames` con valor por defecto `const []`; los posts de demostración existentes siguen renderizando.
- `audience` es `family` cuando hay uno o más niños y `room` cuando la lista está vacía.
- El `Post` se arma con `id` derivado del reloj (`post-<microsecondsSinceEpoch>`), `timeLabel` en `HH:mm` con un formateador puro (sin `intl` en dominio), `likes: 0`, `comments: 0` y `photoLabel: null`.
- Para sala: `childName: 'Toda la sala'`, `recipientNames: const []`, `childInitial: null`, `childColorToken: 'announcement'`, `audience: PostAudience.room`. Es contenido de demostración, no una clave de UI; se acepta la redundancia con la línea "Para: toda la sala".

Etiqueta de audiencia en la tarjeta:

- Sala → `audienceAll`.
- Familia con un destinatario → `audienceFamily(name)`.
- Familia con varios → `audienceFamilies(names)`, con los nombres unidos como "Mateo, Sofía y Benjamín" por un helper puro de UI.
- La cabecera usa el primer niño; es un trade-off de la demo y la línea de audiencia aclara el resto.

Alternativa descartada: un `Post` por cada niño; duplicaría tarjetas y contadores para el mismo momento.

### 5. Contrato de datos y persistencia demo

- `FeedDataSource` suma `Future<void> addPost(Post post)`.
- `FeedRepository` suma `Future<Result<Post>> createPost(Post post)`; `FeedRepositoryImpl` traduce excepciones a `Failure`.
- `DemoFeedDataSource` deja de ser `const`: `_posts` pasa a lista de instancia sembrada desde la plantilla y `addPost` inserta al inicio (`insert(0, post)`), para que la publicación nueva se vea primera. Igual que en niños, cada `ProviderScope` de test obtiene su propia lista.
- `feedDataSourceProvider` deja de crear una instancia `const`.

### 6. Estado del formulario

`CreatePostViewModel extends Notifier<CreatePostState>` con `{ isSaving, errors, publishedPost }`, siguiendo `NewChildViewModel`:

- `submit(PostDraft)` evita doble envío, traduce `PostCreated`/`PostRejected`/`PostFailed` a estado y devuelve el `Post` creado o `null`.
- `clearErrors()` y `reset()`; el formulario resetea en `addPostFrameCallback` porque el provider no es autoDispose y el estado sobreviviría entre visitas.
- Al publicar: `ref.invalidate(feedViewModelProvider)` y `context.go(AppRoutes.home)`. Si falla, se conserva el borrador en los controladores y se muestra un mensaje genérico.

Los textos viven en `TextEditingController`; el estado no los espeja.

### 7. Composición de la UI

```text
CreatePostView (AppShell selectedIndex: 0, scroll, maxWidth 580)
└── CreatePostForm (ConsumerStatefulWidget)
    ├── header: Cancelar | Nueva publicación | Publicar / spinner
    ├── RecipientChips   (selección múltiple; "Toda la sala" exclusiva)
    ├── PostTypeChips    (7 tipos, selección única)
    ├── AppTextField     (DESCRIPCIÓN, maxLines 5, error localizado)
    └── PhotoDropzone    ("Agregar" -> Próximamente)
```

Se reutilizan `AppAvatar`, `AppLink`, `AppTextField`, `AppColors` y `AppTypography`. Contenedor con `loginBackground`, borde `border`, radio 24 y sombra del template; padding 26/24. En anchos menores a 600 px, una columna con padding 20; en mayores, el formulario centrado de hasta 580 px.

Para la lista de niños se usa `kidsViewModelProvider` (ya cachea la sala). Si está cargando o falla, el bloque PARA muestra solo "Toda la sala", cumpliendo el escenario de sala vacía sin bloquear el formulario.

El estado local de destinatarios es un `Set<String>` con orden de inserción: activar un niño lo agrega o lo quita, activar "Toda la sala" lo vacía y quitar el último niño vuelve a seleccionar la sala.

Alternativa descartada: un provider nuevo solo para el composer; duplicaría la carga de niños sin beneficio.

### 8. Localización

Claves nuevas en `app_es.arb`: `composerTitle` (reutiliza `newPost`), `composerCancel`, `composerPublish`, `composerFor`, `composerType`, `composerDescription`, `composerPhotos`, `composerDescriptionHint`, `composerAddPhoto`, `composerBodyRequired`, `composerSaveError`, `composerSaving`, `composerRoomAudience`, `audienceFamilies`, `typeFood`, `typeNap`, `typeMood`, `typePhoto`. La UI no usa cadenas crudas.

## Risks / Trade-offs

- **Ampliar `PostType` rompe `switch` exhaustivos** → el compilador lo detecta; badge, tarjeta, demo y tests se actualizan en la misma tarea.
- **`FeedColors` es verboso** → al agregar cuatro pares hay que tocar `copyWith` y `lerp`; se cubre con el test de tema existente y con el badge de cada tipo.
- **Lista mutable compartida entre tests** → instancia por datasource y provider no `const`, igual que el precedente de niños.
- **Estado del Notifier persiste entre visitas** → `reset()` en el primer frame del formulario.
- **"Toda la sala" como nombre de autor** → redundancia visual aceptada en demo; si molesta, se resuelve en el feed sin cambiar el contrato.
- **Cabecera de una publicación múltiple** → usa el primer niño; la línea de audiencia lista a todos. Si se necesita otra jerarquía visual, se ajusta en la tarjeta sin cambiar el contrato.
- **Posts demo sin `recipientNames`** → la tarjeta cae a `childName` cuando la lista está vacía, sin migración de datos.
- **Fotos no funcionales** → el aviso "Próximamente" deja explícito el alcance y evita prometer un adjunto inexistente.
- **Datos de salud en publicaciones** → son datos de demostración; no se loguean ni se muestran en errores.

## Migration Plan

1. Dominio: `PostType`, `Post.recipientNames`, `PostDraft`, `CreatePost`, contrato del repositorio.
2. Datos: interfaz, datasource mutable, repositorio y providers.
3. UI: ruta, vista, view model, chips, formulario y wiring de entradas.
4. l10n y tokens de color.
5. Tests de dominio, datos, router, widgets e integración.

Sin migración de datos ni rollback especial: revertir el cambio deja el feed en su estado actual y las publicaciones creadas en memoria se pierden al reiniciar.

## Open Questions

Ninguna que afecte specs, enfoque o tareas. El selector de imágenes real queda para un cambio posterior.
