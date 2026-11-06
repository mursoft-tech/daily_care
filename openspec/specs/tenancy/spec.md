# tenancy Specification

## Purpose

Defines the root tenant entity for OpenDayCare and the backend-only access model that isolates daycare data from the public Data API.

## Requirements

### Requirement: Root tenant record

The system SHALL persist each daycare as one row in `public.daycares` with a UUID identifier, a name, an IANA timezone, and creation and update timestamps.

#### Scenario: Valid daycare is inserted

- **WHEN** a row is inserted with a valid name and a Mexican IANA timezone
- **THEN** the row exists with a generated UUID, a creation timestamp, and an update timestamp

#### Scenario: Daycares may share a name

- **WHEN** two daycare rows are inserted with the same name
- **THEN** both rows are stored because names are not unique

### Requirement: Daycare name integrity

The system SHALL accept names between 1 and 120 characters, SHALL reject empty or whitespace-only names, and SHALL reject names with leading or trailing whitespace.

#### Scenario: Normal name is accepted

- **WHEN** the name is `Guardería Sala Soles`
- **THEN** the row is accepted

#### Scenario: Empty name is rejected

- **WHEN** the name is empty or contains only whitespace
- **THEN** the insert is rejected

#### Scenario: Untrimmed name is rejected

- **WHEN** the name has leading or trailing whitespace
- **THEN** the insert is rejected instead of storing the untrimmed value

#### Scenario: Long name is rejected

- **WHEN** the name exceeds 120 characters
- **THEN** the insert is rejected

### Requirement: Mexico timezone constraint

The system SHALL require `timezone` to be one of the twelve IANA timezone names valid for Mexico and SHALL NOT apply a default value.

#### Scenario: Central Mexico timezone is accepted

- **WHEN** the timezone is `America/Mexico_City`
- **THEN** the row is accepted

#### Scenario: Another Mexican timezone is accepted

- **WHEN** the timezone is `America/Cancun` or `America/Tijuana`
- **THEN** the row is accepted

#### Scenario: Foreign timezone is rejected

- **WHEN** the timezone is a valid IANA zone outside Mexico, such as `Europe/Madrid`
- **THEN** the insert is rejected

#### Scenario: Missing timezone is rejected

- **WHEN** the timezone is omitted
- **THEN** the insert is rejected because there is no default

#### Scenario: Legacy alias is rejected

- **WHEN** the timezone uses a non-canonical legacy alias outside the allowlist
- **THEN** the insert is rejected

### Requirement: Backend-only access

The system SHALL enable row-level security on `public.daycares` with no policies, SHALL deny `SELECT`, `INSERT`, `UPDATE`, and `DELETE` to `anon` and `authenticated`, and SHALL allow those operations only through `service_role`.

#### Scenario: Anonymous read is denied

- **WHEN** a request runs as `anon` and selects from `public.daycares`
- **THEN** the database returns a permission-denied error instead of rows

#### Scenario: Authenticated read is denied

- **WHEN** a signed-in request runs as `authenticated` and selects from `public.daycares`
- **THEN** the database returns a permission-denied error instead of rows

#### Scenario: Anonymous write is denied

- **WHEN** a request runs as `anon` and attempts to insert, update, or delete a daycare
- **THEN** the database returns a permission-denied error

#### Scenario: Backend access is allowed

- **WHEN** the request runs as `service_role`
- **THEN** it can select, insert, update, and delete daycare rows

### Requirement: Update timestamp maintenance

The system SHALL update `updated_at` to the current timestamp on every update of a daycare row and SHALL preserve `created_at`.

#### Scenario: Update refreshes the timestamp

- **WHEN** an existing daycare changes its name
- **THEN** `updated_at` becomes newer and `created_at` remains unchanged

### Requirement: Demo seed

The system SHALL provide a separate seed migration that inserts one demo daycare with a stable UUID, a valid name, and a Mexican timezone.

#### Scenario: Seed creates the demo daycare

- **WHEN** all migrations have been applied to a fresh project
- **THEN** exactly one demo daycare exists with the documented UUID and a timezone from the Mexican allowlist
