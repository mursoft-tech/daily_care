# Spec Delta

## MODIFIED Requirements

### Requirement: Allergy notes

La ficha SHALL mostrar el bloque "Alergias y notas" con una etiqueta corta por cada alergia registrada, el detalle de cada alergia y las notas médicas del niño, y SHALL omitir el bloque solo cuando no hay alergias ni notas médicas.

#### Scenario: Niño con alergia

- **WHEN** el usuario abre la ficha de Mateo Fernández
- **THEN** ve "Alergias y notas", la etiqueta "MANÍ" y el detalle "Alergia al maní. Evitar frutos secos. Lleva inhalador en la mochila."

#### Scenario: Niño con varias alergias

- **WHEN** el usuario abre la ficha de un niño con dos alergias registradas
- **THEN** ve una etiqueta por cada alergia en el bloque "Alergias y notas"

#### Scenario: Niño solo con notas médicas

- **WHEN** el usuario abre la ficha de un niño sin alergias pero con notas médicas
- **THEN** el bloque "Alergias y notas" muestra las notas médicas y no muestra etiquetas de alergia

#### Scenario: Niño sin alergia

- **WHEN** el usuario abre la ficha de Sofía Méndez
- **THEN** no se muestra el bloque "Alergias y notas"
