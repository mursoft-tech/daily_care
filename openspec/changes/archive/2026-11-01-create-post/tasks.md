# Tasks

## 1. Dominio y tipos

- [x] 1.1 Ampliar `PostType` a `{ food, nap, activity, achievement, mood, photo, announcement }` y actualizar los `switch` exhaustivos de `PostTypeBadge` y `FeedPostCard` (megáfono por `PostAudience.room`); verificar con `flutter analyze` y un test de badge para los siete tipos.
- [x] 1.2 Agregar los tokens de color de los cuatro tipos nuevos en `AppColors` y extender `FeedColors` (`copyWith` y `lerp`); verificar que `test/ui/core/widgets/app_atoms_test.dart` y un test de `PostTypeBadge` pasen sin colores nulos.
- [x] 1.3 Crear `PostDraft` (`childIds`, `type`, `body`) con lista vacía por defecto, normalización de la descripción y helpers para distinguir sala de familia; verificar con `test/domain/value_objects/post_draft_test.dart`.
- [x] 1.4 Crear `CreatePost` con validación de descripción, resolución de cada niño seleccionado, instantánea del primero, `recipientNames`, hora `HH:mm` y resultado sellado (`PostCreated`/`PostRejected`/`PostFailed`); verificar con `test/domain/use_cases/create_post_test.dart` cubriendo un niño, varios, sala, descripción vacía, niño inexistente y fallo de guardado.
- [x] 1.5 Agregar `recipientNames` (por defecto `const []`) a `Post` y mostrar en la tarjeta la audiencia de varias familias; verificar con `test/ui/features/feed/feed_post_card_test.dart` para uno, varios y sala.

## 2. Datos y providers

- [x] 2.1 Sumar `addPost(Post)` a `FeedDataSource`, convertir `DemoFeedDataSource` en lista de instancia sembrada desde la plantilla e insertar la publicación al inicio; verificar con un test de repositorio que la nueva publicación quede primera.
- [x] 2.2 Sumar `createPost(Post)` a `FeedRepository` e implementarlo en `FeedRepositoryImpl` traduciendo excepciones a `Failure`; verificar `test/data/repositories/feed_repository_test.dart` con éxito y fallo.
- [x] 2.3 Registrar `createPostUseCaseProvider` y dejar `feedDataSourceProvider` con instancia no `const`; verificar con `test/app/providers_test.dart` que dos contenedores no compartan publicaciones.

## 3. Formulario de publicación

- [x] 3.1 Declarar `AppRoutes.newPost = '/publicaciones/nueva'`, la `GoRoute` y `CreatePostView` con `AppShell(selectedIndex: 0)` y contenedor de hasta 580 px; verificar con un test de router que la ruta renderiza el formulario y "Feed" queda resaltado.
- [x] 3.2 Implementar `CreatePostViewModel` (`isSaving`, `errors`, `publishedPost`, `submit`, `clearErrors`, `reset`); verificar con tests de estado para validación, éxito y fallo.
- [x] 3.3 Crear los widgets del formulario (encabezado Cancelar/Publicar, chips de destinatario con selección múltiple, chips de tipo con selección marcada, descripción y bloque FOTOS con "Próximamente"); verificar con tests de widget para varios niños, sala exclusiva, último niño, error de descripción y aviso de foto.
- [x] 3.4 Conectar el formulario con `kidsViewModelProvider`, `CreatePostViewModel` y la navegación de vuelta al feed, invalidando `feedViewModelProvider` al publicar; verificar con un test de widget que el `Post` creado llega al repositorio y se navega a `/`.
- [x] 3.5 Ajustar el layout responsive (una columna bajo 600 px, centrado por encima) y verificar sin overflow en 400, 800 y 1200 px.
- [x] 3.6 Cablear `ComposerBar.onTap` y `AppNavigationPanel.onNewPost` desde `AppShell` (cerrando el drawer antes de navegar); verificar con tests de `home_view` y `app_navigation_panel` que ambos navegan a `/publicaciones/nueva` sin "Próximamente".

## 4. Localización y verificación integrada

- [x] 4.1 Agregar las claves `composer*`, `audienceFamilies` y `typeFood/typeNap/typeMood/typePhoto` a `app_es.arb` y regenerar con `flutter gen-l10n`; verificar que no queden textos crudos en el formulario y que `flutter analyze` pase.
- [x] 4.2 Escribir el test de integración "crear publicación": composer → elegir dos niños → tipo → descripción → Publicar → feed con la publicación primera y la audiencia de ambas familias; verificar con `flutter test integration_test/create_post_flow_test.dart`.
- [x] 4.3 Ejecutar `flutter analyze` y `flutter test` completos y corregir cualquier regresión en feed, shell o repositorios.

## Workflow follow-up

- Archivar el change una vez cumplidos los requisitos de revisión del proyecto.
- Verificar el resultado archivado.
