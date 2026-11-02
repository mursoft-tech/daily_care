# Spec Delta

## MODIFIED Requirements

### Requirement: Post card presentation

Cada publicación SHALL mostrar autor, hora, audiencia, tipo (comida, siesta, actividad, logro, ánimo, foto o anuncio), cuerpo, contadores de likes y comentarios, y la acción "Editar".

#### Scenario: Publicación de logro

- **WHEN** se renderiza una publicación de tipo logro
- **THEN** la tarjeta muestra el badge verde "LOGRO" y el texto dirigido a la familia

#### Scenario: Publicación con foto

- **WHEN** una publicación de actividad incluye una foto
- **THEN** la tarjeta muestra un placeholder punteado con el ícono de imagen y la etiqueta de la foto

#### Scenario: Publicación de anuncio

- **WHEN** se renderiza un anuncio general
- **THEN** la tarjeta muestra el badge azul "ANUNCIO" y la audiencia "toda la sala"

#### Scenario: Publicación de los tipos nuevos

- **WHEN** se renderiza una publicación de tipo comida, siesta, ánimo o foto
- **THEN** la tarjeta muestra la etiqueta y el color correspondientes a ese tipo

#### Scenario: Publicación para varias familias

- **WHEN** se renderiza una publicación dirigida a dos o más niños
- **THEN** la tarjeta muestra en la audiencia los nombres de todos los destinatarios

### Requirement: Navigation affordances

Todo elemento interactivo de la plantilla SHALL comportarse como enlace: muestra cursor de mano al pasar el puntero, responde a teclado y, al activarse, ejecuta su acción. Los destinos "Feed" y "Niños" SHALL navegar a `/` y `/kids`; el composer y el botón "Nueva publicación" SHALL navegar a `/publicaciones/nueva`; el resto de los enlaces no implementados SHALL mostrar el aviso "Próximamente" sin navegar a otra ruta. La acción de logout queda exceptuada y navega a `/login`.

#### Scenario: Hover sobre un enlace

- **WHEN** el puntero se posiciona sobre "Niños", "Avisos", "Mi cuenta", "Nueva publicación" o cualquier enlace del feed
- **THEN** el cursor cambia a mano

#### Scenario: Navegación a niños

- **WHEN** el usuario activa "Niños"
- **THEN** la aplicación navega a `/kids` sin mostrar el aviso "Próximamente"

#### Scenario: Navegación al feed

- **WHEN** el usuario activa "Feed" desde otra ruta
- **THEN** la aplicación navega a `/` sin mostrar el aviso "Próximamente"

#### Scenario: Navegación desde el composer

- **WHEN** el usuario activa el composer del feed
- **THEN** la aplicación navega a `/publicaciones/nueva` sin mostrar el aviso "Próximamente"

#### Scenario: Navegación desde el botón de nueva publicación

- **WHEN** el usuario activa "Nueva publicación" en el sidebar o en el menú lateral
- **THEN** el menú lateral se cierra si estaba abierto y la aplicación navega a `/publicaciones/nueva`

#### Scenario: Activación de un enlace

- **WHEN** el usuario hace clic o presiona Enter sobre un enlace no implementado
- **THEN** aparece el aviso "Próximamente" y la ruta actual no cambia

#### Scenario: Activación del logout

- **WHEN** el usuario activa la acción de cerrar sesión
- **THEN** la aplicación navega a `/login` sin mostrar el aviso "Próximamente"
