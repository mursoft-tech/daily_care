# Rollback: create-daycares-table

Supabase migrations are forward-only. To undo this change, apply a **new** migration named `rollback_create_daycares`; never edit `create_daycares` or `seed_demo_daycare`.

## Preconditions

Check whether `public.set_updated_at()` is shared with another table:

```sql
select tgrelid::regclass as table_name, tgname
from pg_trigger
where tgfoid = 'public.set_updated_at()'::regprocedure
  and not tgisinternal;
```

If the only result is `public.daycares`, drop the function too. If another table uses it, drop only the table and keep the function.

## Compensating migration

```sql
drop table public.daycares;
drop function public.set_updated_at();
```

`drop table` also removes the trigger, the table grants, the table comment, and the seeded demo row. The seed row has no independent cleanup step.

## Effect on migration history

The project keeps all three entries in `supabase_migrations.schema_migrations`:

1. `create_daycares`
2. `seed_demo_daycare`
3. `rollback_create_daycares`

The history is append-only; the rollback is auditable, not a deletion.

## Verification

```sql
select to_regclass('public.daycares') is null as table_dropped;
select to_regprocedure('public.set_updated_at()') is null as function_dropped;
```

Both must return `true` when the function was not shared.
