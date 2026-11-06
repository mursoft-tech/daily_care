# Design

## Context

The remote Supabase project is empty: no tables, no migration history, and no domain users. It runs PostgreSQL 17.11, so the native PostgreSQL 18 `uuidv7()` function is unavailable. The project already has an `ensure_rls` event trigger that enables row-level security on new `public` tables, and its default ACL grants broad privileges to `anon`, `authenticated`, and `service_role`.

The backend will use `supabase-js` with `service_role`, which means it reaches the database through PostgREST. That requires the table to live in the exposed `public` schema.

See `proposal.md` for motivation and `specs/tenancy/spec.md` for the behavior contract.

## Goals / Non-Goals

**Goals:**

- Create the root tenant table with strict name and timezone constraints.
- Establish a backend-only access posture that no client role can bypass.
- Keep the schema reproducible through tracked Supabase migrations, including a demo seed.
- Leave the table ready for future tenant-scoped tables to reference.

**Non-Goals:**

- Creating `users`, `rooms`, `children`, or any other domain table.
- Adding client-facing RLS policies or client reads of `daycares`.
- Adding soft delete, lifecycle status, slug, locale, or contact fields.
- Building the onboarding endpoint or the Flutter client integration.
- Seeding an auth user or a domain user.

## Decisions

### PostgreSQL 17 and UUIDv4 identifiers

Use `uuid` primary keys with `DEFAULT gen_random_uuid()`. The remote project is PostgreSQL 17, where `uuidv7()` does not exist, and `pg_uuidv7` is not installed.

Alternatives considered:

- **Application-generated UUIDv7**: works, but adds coordination and is unnecessary for a table with one row per tenant.
- **Custom SQL UUIDv7 function**: adds a maintenance burden and a name collision risk if the project later upgrades to PostgreSQL 18.

The column type remains `uuid` if a future high-volume table adopts UUIDv7; generation strategy can vary per table without migrating foreign keys.

### `public` schema

Place the table in `public` because the backend uses PostgREST through `supabase-js`. A non-exposed schema would force direct SQL connections and complicate the backend.

The protection is therefore explicit grants plus RLS, not schema obscurity.

### Backend-only access posture

Enable RLS with no policies, revoke all privileges from `PUBLIC`, `anon`, `authenticated`, and `service_role`, then grant only `SELECT`, `INSERT`, `UPDATE`, and `DELETE` to `service_role`. `TRUNCATE`, `REFERENCES`, and `TRIGGER` are unnecessary for the backend and stay revoked.

Alternatives considered:

- **Client reads its own daycare via `app_metadata`**: viable later, but requires an onboarding flow that sets the claim and a new migration to restore grants.
- **Policy that reads `public.users`**: impossible now because the table does not exist, and it needs a `SECURITY DEFINER` helper to avoid RLS recursion.

The chosen posture means the Data API returns permission-denied, not an empty result, which makes the boundary observable and testable.

### Mexico-only timezone allowlist

Store `timezone` as `text NOT NULL` with a `CHECK` against the twelve canonical IANA zones for Mexico. Do not use an enum: an enum requires a type migration when tzdata changes, while a check constraint is easier to adjust. Do not use a regex alone: it accepts typos and rejects valid names such as `UTC`.

The twelve zones are:

`America/Bahia_Banderas`, `America/Cancun`, `America/Chihuahua`, `America/Ciudad_Juarez`, `America/Hermosillo`, `America/Matamoros`, `America/Mazatlan`, `America/Merida`, `America/Mexico_City`, `America/Monterrey`, `America/Ojinaga`, `America/Tijuana`.

No default value is applied. A silent default would misplace daily summaries and 19:00 notifications for daycares outside central Mexico.

### Strict name constraint

Use a single check that enforces length 1–120 and `name = btrim(name)`. This rejects empty, whitespace-only, and untrimmed values. The backend is responsible for trimming input; the database refuses to store a value it would otherwise have to normalize silently.

Alternative considered: a `BEFORE INSERT OR UPDATE` trigger that trims automatically. It is friendlier but hides bad input, and this table has a single trusted writer.

### Reusable `updated_at` trigger

Create `public.set_updated_at()` as a `SECURITY INVOKER` trigger function with `SET search_path = ''` and attach it to `daycares`. The function only assigns `NEW.updated_at := now()`.

Alternative considered: the `moddatetime` extension. It is available but adds an extension dependency for five lines of logic. The function can be reused by later tables.

### Seed as a separate data migration

Create `seed_demo_daycare` after `create_daycares`. It inserts one row with the fixed UUID `11111111-1111-4111-8111-111111111111`, the name `Guardería Sala Soles`, and the timezone `America/Mexico_City`.

A fixed UUID makes the demo row referenceable from later migrations and from `app_metadata` without guessing. A plain `INSERT` is used because the migration is tracked and runs once; a duplicate is a real error, not a case to swallow with `ON CONFLICT DO NOTHING`.

Alternative considered: `supabase/seed.sql`, which only applies to local resets and cannot seed this remote project through the MCP migration path.

### Tracked Supabase migrations

Apply the change through the Supabase MCP `apply_migration` tool, which creates the `supabase_migrations.schema_migrations` history on first use. Migration files are forward-only; a rollback is a new compensating migration, never an edit to an applied one.

Do not use `CREATE TABLE IF NOT EXISTS`: a clean project should fail loudly on drift.

## Risks / Trade-offs

- **`service_role` bypasses RLS** → The backend is the only tenant guard for this table. Mitigation: derive `daycare_id` from the authenticated session, never from the request body, and add composite tenant foreign keys when child tables arrive.
- **Advisors flag RLS without policies** → The state is intentional. Mitigation: add a table comment that explains the backend-only posture so it is not "fixed" with an open policy.
- **Static timezone allowlist** → A tzdata change could add or rename a Mexican zone. Mitigation: review the list on PostgreSQL upgrades and adjust with a new migration.
- **Demo seed in a production project** → The row is real data. Mitigation: remove it with a compensating migration before production use.
- **Revoked grants block future client access** → Any future client read requires a new migration that restores grants and adds a policy. This is deliberate friction, not an oversight.
- **PostgreSQL 17 lacks UUIDv7** → IDs are random rather than time-ordered. Acceptable for a tenant root table; revisit for high-volume tables.

## Migration Plan

1. Apply `create_daycares`: table, named constraints, RLS enabled, revokes, `service_role` grants, `set_updated_at()` and its trigger, and the table comment.
2. Apply `seed_demo_daycare`: one fixed-UUID demo row.
3. Verify with `list_tables`, `list_migrations`, `has_table_privilege`, `pg_class.relrowsecurity`, a `SET LOCAL ROLE anon` select expecting permission denied, and `get_advisors`.
4. Rollback, if ever needed, with a compensating migration that drops the table and the trigger function. Both migrations then appear in `list_migrations`; no applied migration is edited.

## Open Questions

None. Deferred fields and the onboarding flow are explicit non-goals, not unresolved design questions.
