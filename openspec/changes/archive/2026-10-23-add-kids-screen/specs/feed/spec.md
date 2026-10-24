# Spec Delta

## MODIFIED Requirements

### Requirement: Navigation affordances

Todo elemento interactivo de la plantilla SHALL comportarse como enlace: muestra cursor de mano al pasar el puntero, responde a teclado y, al activarse, ejecuta su acción. Los destinos "Feed" y "Niños" SHALL navegar a `/` y `/kids`; el resto de los enlaces no implementados SHALL mostrar el aviso "Próximamente" sin navegar a otra ruta. La acción de logout queda exceptuada y navega a `/login`.

#### Scenario: Hover sobre un enlace

- **WHEN** el puntero se posiciona sobre "Niños", "Avisos", "Mi cuenta", "Nueva publicación" o cualquier enlace del feed
- **THEN** el cursor cambia a mano

#### Scenario: Navegación a niños

- **WHEN** el usuario activa "Niños"
- **THEN** la aplicación navega a `/kids` sin mostrar el aviso "Próximamente"

#### Scenario: Navegación al feed

- **WHEN** el usuario activa "Feed" desde otra ruta
- **THEN** la aplicación navega a `/` sin mostrar el aviso "Próximamente"

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
- **THEN** el panel se cierra y, si el destino está implementado, la aplicación navega a su ruta; si no, se conserva la ruta actual
