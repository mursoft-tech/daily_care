# Proposal

## Why

El composer del feed y el botón "Nueva publicación" del panel todavía caen en el aviso "Próximamente": la maestra no tiene forma de registrar el día desde la app. La plantilla `docs/templates/crear-publicacion.dc.html` ya define el flujo, y el proyecto opera con datos de demostración en memoria, así que se puede completar sin base de datos ni API.

## What Changes

- Nueva ruta `/publicaciones/nueva` con una vista fiel al template: encabezado "Cancelar / Nueva publicación / Publicar", bloques PARA, TIPO, DESCRIPCIÓN y FOTOS, dentro del shell con "Feed" resaltado.
- El composer del home y el botón "Nueva publicación" del panel (sidebar y menú lateral) navegan a esa ruta; el menú lateral se cierra antes de navegar.
- **BREAKING**: `PostType` pasa de 3 a 7 valores (`food`, `nap`, `activity`, `achievement`, `mood`, `photo`, `announcement`). Los `switch` exhaustivos del badge y la tarjeta deben cubrir los nuevos tipos.
- Selección múltiple de destinatarios: se pueden marcar varios niños de la sala; "Toda la sala" queda excluida y, al activarla, deselecciona a todos. La descripción es obligatoria; el tipo tiene un valor por defecto y es editable.
- "Publicar" crea un único `Post` dirigido a todas las familias seleccionadas en el datasource demo y vuelve a `/`; la publicación nueva aparece primera en el feed.
- El bloque FOTOS se mantiene visualmente fiel, pero "Agregar" sigue mostrando "Próximamente": no hay adjunto real ni selector de imágenes en esta etapa.
- Nuevas claves de localización y tokens de color para los cuatro tipos nuevos.

Fuera de alcance: "Editar" publicaciones, persistencia real (drift/sqflite/API), adjuntar o mostrar imágenes reales, crear una publicación por cada niño seleccionado, comentarios y likes.

## Capabilities

### New Capabilities

- `post-creation`: flujo de creación de una publicación desde el feed, con ruta dedicada, formulario de destinatarios/tipo/descripción, validación y publicación en memoria.

### Modified Capabilities

- `feed`: los accesos "Nueva publicación" y composer dejan de mostrar "Próximamente" y navegan al formulario; la tarjeta de publicación reconoce los siete tipos y el feed refleja una publicación recién creada.

## Impact

- `lib/app/router/app_routes.dart`, `lib/app/router/app_router.dart`.
- `lib/domain/models/post_type.dart`, `lib/domain/models/post.dart`, `lib/domain/value_objects/post_draft.dart`, `lib/domain/use_cases/create_post.dart`, `lib/domain/repositories/feed_repository.dart`.
- `lib/data/datasources/feed_data_source.dart`, `lib/data/datasources/local/demo_feed_datasource.dart`, `lib/data/repositories/feed_repository_impl.dart`.
- `lib/app/providers.dart`.
- `lib/ui/features/feed/` (vista, view model, widgets, composer, tarjeta, badge) y `lib/ui/core/widgets/app_navigation_panel.dart` con `app_shell.dart`.
- `lib/app/theme/app_colors.dart` y `lib/l10n/app_es.arb`.
- Tests de router, feed, repositorio, view/view model e integración.
- Sin dependencias nuevas ni cambios de backend.
