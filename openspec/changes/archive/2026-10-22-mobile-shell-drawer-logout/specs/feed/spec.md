# Spec Delta

## MODIFIED Requirements

### Requirement: Navigation affordances
Todo elemento interactivo de la plantilla SHALL comportarse como enlace: muestra cursor de mano al pasar el puntero, responde a teclado y, al activarse, muestra el aviso "Próximamente" sin navegar a otra ruta. La acción de logout queda exceptuada y navega a `/login`.

#### Scenario: Hover sobre un enlace
- **WHEN** el puntero se posiciona sobre "Niños", "Avisos", "Mi cuenta", "Nueva publicación" o cualquier enlace del feed
- **THEN** el cursor cambia a mano

#### Scenario: Activación de un enlace
- **WHEN** el usuario hace clic o presiona Enter sobre un enlace no implementado
- **THEN** aparece el aviso "Próximamente" y la ruta actual no cambia

#### Scenario: Activación del logout
- **WHEN** el usuario activa la acción de cerrar sesión
- **THEN** la aplicación navega a `/login` sin mostrar el aviso "Próximamente"

### Requirement: Adaptive shell
El shell SHALL adaptarse al ancho disponible: sidebar completo en anchos grandes, rail de íconos en anchos medios y barra superior con menú lateral en anchos compactos, conservando los destinos Feed, Niños, Avisos y Mi cuenta.

#### Scenario: Ancho grande
- **WHEN** el ancho disponible es de 900 px o más
- **THEN** se muestra el sidebar de 248 px con logo, botón de nueva publicación, navegación y cuenta

#### Scenario: Ancho medio
- **WHEN** el ancho disponible está entre 600 y 899 px
- **THEN** se muestra un rail de íconos con los mismos destinos

#### Scenario: Ancho compacto
- **WHEN** el ancho disponible es menor a 600 px
- **THEN** se muestra una barra superior con el botón de menú y el contenido ocupa el ancho restante sin overflow

#### Scenario: Menú lateral en ancho compacto
- **WHEN** el usuario activa el botón de menú
- **THEN** se abre un panel lateral con marca, botón de nueva publicación, los cuatro destinos y el bloque de cuenta

#### Scenario: Cierre del menú lateral
- **WHEN** el usuario elige un destino del menú lateral
- **THEN** el panel se cierra y se conserva la ruta actual

## ADDED Requirements

### Requirement: Logged-in user visibility
El shell SHALL exponer el usuario logueado en los tres anchos: nombre y rol en el sidebar y en el menú lateral, y avatar en la barra superior compacta y en el rail.

#### Scenario: Identidad en ancho compacto
- **WHEN** el usuario abre el menú lateral en un ancho menor a 600 px
- **THEN** ve el nombre y el rol del usuario logueado junto a su avatar

#### Scenario: Identidad en anchos mayores
- **WHEN** el ancho es de 600 px o más
- **THEN** el avatar del usuario es visible en el rail o el sidebar

### Requirement: Logout navigation
La aplicación SHALL ofrecer una acción de cierre de sesión en los tres anchos que navegue a la ruta `/login`.

#### Scenario: Logout en ancho compacto
- **WHEN** el usuario activa el cierre de sesión desde la barra superior o el menú lateral
- **THEN** la aplicación muestra la pantalla de `/login`

#### Scenario: Logout en anchos mayores
- **WHEN** el usuario activa el cierre de sesión desde el sidebar o el rail
- **THEN** la aplicación muestra la pantalla de `/login`

#### Scenario: Pantalla de login placeholder
- **WHEN** se muestra `/login` en esta etapa
- **THEN** la pantalla no solicita credenciales, no valida identidad y no deja sesión iniciada

### Requirement: Safe areas
El shell SHALL respetar las áreas seguras del sistema para que la barra de estado y la barra de gestos no oculten contenido ni acciones.

#### Scenario: Barra de estado en Android
- **WHEN** la aplicación corre en un dispositivo con barra de estado visible
- **THEN** la cabecera del feed y el botón de menú no quedan tapados por el sistema

#### Scenario: Barra de gestos
- **WHEN** el sistema reserva un inset inferior
- **THEN** el contenido y las acciones del shell no quedan debajo de esa zona
