# Proposal

## Why

The remote Supabase project has no tables. `daycares` is the root tenant entity that every other domain table will reference, so it must exist before users, rooms, children, or content can be modeled.

The table is also the first place to establish the project's access posture: backend-only through `service_role`, with no direct Data API exposure.

## What Changes

- Create `public.daycares` with `id`, `name`, `timezone`, `created_at`, and `updated_at`.
- Constrain `name` to 1–120 characters, non-empty and trimmed.
- Constrain `timezone` to the twelve IANA zones valid for Mexico.
- Enable row-level security with no policies, revoke access from `anon` and `authenticated`, and grant access only to `service_role`.
- Add a reusable `set_updated_at()` trigger function to maintain `updated_at`.
- Seed one demo daycare with a fixed, documented UUID in a separate data migration.

## Capabilities

### New Capabilities

- `tenancy`: root tenant identity, its Mexico timezone constraint, and the backend-only access model for tenant data.

### Modified Capabilities

None.

## Impact

- Affects the remote Supabase project only: one table, one trigger, one seed row, and the first entry in its migration history.
- No Flutter, backend, or API code changes in this change.
- `anon` and `authenticated` get permission-denied instead of rows; all reads and writes must go through the backend with `service_role`.
- Future tables will reference `daycares(id)` and inherit its tenant boundary.
- PostgreSQL 17 is used in the remote project, so IDs rely on `gen_random_uuid()` rather than the PostgreSQL 18 `uuidv7()`.
