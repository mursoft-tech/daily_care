# Spec Delta

## Purpose

Presenta el feed del home con las publicaciones de la sala, el acceso al composer y la navegación principal, manteniendo la identidad visual de la plantilla de referencia.

## ADDED Requirements

### Requirement: Home feed content
En la ruta `/`, el sistema SHALL mostrar la cabecera del feed (saludo, cantidad de niños y fecha), el composer de publicación, la etiqueta de sección "PUBLICADO HOY" y la lista de publicaciones.

#### Scenario: Feed con publicaciones
- **WHEN** el usuario abre `/`
- **THEN** ve el saludo "Buenas, Caro", el resumen "12 niños · martes 17 jun", el composer y las tres publicaciones de demostración

#### Scenario: Scroll del contenido
- **WHEN** la lista de publicaciones excede la altura de la ventana
- **THEN** el contenido principal hace scroll mientras el sidebar permanece visible

### Requirement: Post card presentation
Cada publicación SHALL mostrar autor, hora, audiencia, tipo (logro, actividad o anuncio), cuerpo, contadores de likes y comentarios, y la acción "Editar".

#### Scenario: Publicación de logro
- **WHEN** se renderiza una publicación de tipo logro
- **THEN** la tarjeta muestra el badge verde "LOGRO" y el texto dirigido a la familia

#### Scenario: Publicación con foto
- **WHEN** una publicación de actividad incluye una foto
- **THEN** la tarjeta muestra un placeholder punteado con el ícono de imagen y la etiqueta de la foto

#### Scenario: Publicación de anuncio
- **WHEN** se renderiza un anuncio general
- **THEN** la tarjeta muestra el badge azul "ANUNCIO" y la audiencia "toda la sala"

### Requirement: Feed states
El sistema SHALL representar los estados de carga, error y datos del feed sin bloquear el shell de navegación.

#### Scenario: Carga inicial
- **WHEN** el feed aún no tiene datos
- **THEN** se muestra un indicador de progreso en el área de contenido y el sidebar sigue disponible

#### Scenario: Error de carga
- **WHEN** el feed falla
- **THEN** se muestra un mensaje genérico sin detalles internos y una acción para reintentar

### Requirement: Navigation affordances
Todo elemento `<a>` de la plantilla SHALL comportarse como enlace: muestra cursor de mano al pasar el puntero, responde a teclado y, al activarse, muestra el aviso "Próximamente" sin navegar a otra ruta.

#### Scenario: Hover sobre un enlace
- **WHEN** el puntero se posiciona sobre "Niños", "Avisos", "Mi cuenta", "Nueva publicación" o cualquier enlace del feed
- **THEN** el cursor cambia a mano

#### Scenario: Activación de un enlace
- **WHEN** el usuario hace clic o presiona Enter sobre un enlace no implementado
- **THEN** aparece el aviso "Próximamente" y la ruta actual no cambia

### Requirement: Adaptive shell
El shell SHALL adaptarse al ancho disponible: sidebar completo en anchos grandes, rail de íconos en anchos medios y barra inferior en anchos compactos, conservando los destinos Feed, Niños, Avisos y Mi cuenta.

#### Scenario: Ancho grande
- **WHEN** el ancho disponible es de 900 px o más
- **THEN** se muestra el sidebar de 248 px con logo, botón de nueva publicación, navegación y cuenta

#### Scenario: Ancho medio
- **WHEN** el ancho disponible está entre 600 y 899 px
- **THEN** se muestra un rail de íconos con los mismos destinos

#### Scenario: Ancho compacto
- **WHEN** el ancho disponible es menor a 600 px
- **THEN** se muestra una `NavigationBar` inferior y el contenido ocupa el ancho restante sin overflow

### Requirement: Spanish localization
El sistema SHALL presentar todos los textos de interfaz en español y formatear la fecha del home según el locale `es`.

#### Scenario: Textos localizados
- **WHEN** el usuario abre el home
- **THEN** la navegación, el composer, los badges, las acciones y los estados muestran textos en español provenientes de la localización, sin claves crudas

#### Scenario: Fecha en español
- **WHEN** se renderiza el resumen de la cabecera
- **THEN** la fecha aparece como "martes 17 jun" con el formato del locale `es`

### Requirement: Offline demo data
El home SHALL renderizar el feed sin depender de red, autenticación ni base de datos, usando datos de demostración provistos por la capa de datos.

#### Scenario: Sin conectividad
- **WHEN** el dispositivo no tiene red
- **THEN** el feed de demostración se muestra igualmente
