# Tasks

## 1. Preflight

- [x] 1.1 Confirm the remote project has no `daycares` table and no prior migration, verifying with `list_tables` and `list_migrations`
- [x] 1.2 Confirm all twelve Mexican IANA zones still exist in `pg_timezone_names`, verifying that the query returns twelve rows including `America/Mexico_City`

## 2. Schema Migration

- [x] 2.1 Apply the `create_daycares` migration with the UUID primary key, name checks, timezone allowlist, and timestamps, verifying `list_tables` reports the expected columns and named constraints
- [x] 2.2 Add the explicit RLS enable, revoke all privileges from `PUBLIC`, `anon`, `authenticated`, and `service_role`, and grant only CRUD to `service_role`, verifying `pg_class.relrowsecurity` is true and the privilege matrix matches the design
- [x] 2.3 Create `public.set_updated_at()` and its `daycares` trigger, verifying the trigger exists in `pg_trigger` and an update refreshes `updated_at`
- [x] 2.4 Add the backend-only table comment, verifying `obj_description` returns the documented text

## 3. Demo Seed

- [x] 3.1 Apply the `seed_demo_daycare` migration with the fixed UUID `11111111-1111-4111-8111-111111111111`, verifying exactly one row exists with the expected name and `America/Mexico_City`

## 4. Security Verification

- [x] 4.1 Verify `anon` and `authenticated` receive permission-denied on `SELECT`, `INSERT`, `UPDATE`, and `DELETE`, while `service_role` succeeds
- [x] 4.2 Run `get_advisors` for security, verifying there are no unexpected findings beyond the intentional RLS-without-policies state

## 5. Operational Closeout

- [x] 5.1 Document the compensating rollback migration that would drop the table and trigger function, verifying the procedure names the objects and does not edit applied migrations
- [x] 5.2 Verify `list_migrations` records `create_daycares` before `seed_demo_daycare` and both names match the design
