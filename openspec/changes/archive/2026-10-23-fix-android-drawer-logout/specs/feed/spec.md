# Spec Delta

## MODIFIED Requirements

### Requirement: Logout navigation
La aplicación SHALL ofrecer una acción de cierre de sesión en los tres anchos, con un área táctil de al menos 48x48 dp, que cierre el menú lateral si está abierto y navegue a la ruta `/login`.

#### Scenario: Logout en ancho compacto
- **WHEN** el usuario activa el cierre de sesión desde la barra superior o el menú lateral
- **THEN** la aplicación muestra la pantalla de `/login`

#### Scenario: Logout en anchos mayores
- **WHEN** el usuario activa el cierre de sesión desde el sidebar o el rail
- **THEN** la aplicación muestra la pantalla de `/login`

#### Scenario: Cierre del menú lateral al salir
- **WHEN** el usuario activa el cierre de sesión con el menú lateral abierto
- **THEN** el menú deja de estar visible y la pantalla de `/login` ocupa la aplicación

#### Scenario: Toque impreciso sobre el cierre de sesión
- **WHEN** el usuario toca cualquier punto del área táctil de la acción de cierre de sesión, sin necesidad de acertar el centro
- **THEN** la aplicación navega a `/login`

#### Scenario: Área táctil mínima
- **WHEN** se renderiza la acción de cierre de sesión en cualquier ancho
- **THEN** su área interactiva mide al menos 48x48 dp

#### Scenario: Pantalla de login placeholder
- **WHEN** se muestra `/login` en esta etapa
- **THEN** la pantalla no solicita credenciales, no valida identidad y no deja sesión iniciada
