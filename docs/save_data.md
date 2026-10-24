# Save data contract and migration

## Location, schema and invariants

`SaveRepository` stores JSON in `user://player_state.json`. Examples are in `tests/fixtures/`. Current schema is **2**:

```json
{
  "schema_version": 2,
  "profile": { "best_score": 120, "coins": 53 },
  "settings": { "sound_enabled": false }
}
```

`SaveValidator` rejects missing keys, invalid types and negative counters. `SaveMigrator` knows an explicit **v1 -> v2** step converting `gold` into `profile.coins`. Unknown future versions fail closed. `record_run` applies `max()` to best score and accumulates newly earned coins. Save is committed once at run end/exit, not every frame.

## Failure behavior

1. On load: validate and migrate the primary file; otherwise validate `.bak`.
2. If neither can be read, and a save existed, **enable read-only protection**; do not write defaults over player data. New installs with no save use default v2.
3. On write: validate a full draft, serialize to `.tmp`, read/validate the temp file, back up a known-valid prior main file, then replace main. `.bak` is not overwritten from a corrupt main.
4. `DirAccess.rename_absolute` is best-effort across filesystems; do not claim strict crash-safe transactionality or encryption. This starter doesn't support multi-process writers.
5. If write fails, keep the in-memory state unchanged and report `last_error` to the UI/log. Read-only persisted data must be repaired before further writes.

## New schema changes

Example v2 -> v3:

- Increase `SaveValidator.CURRENT_SCHEMA`.
- Add **sequential** v2-to-v3 migration in `SaveMigrator`. Do not skip old versions.
- Keep v1 and v2 fixture files unchanged. Add v3 fixture. Test v1 -> v3 and v2 -> v3.
- Add tests for malformed JSON, missing fields, negative values, non-ASCII names if applicable, unknown future versions, backup recovery, and interrupted writes.
- Do not change IDs because a scene is renamed or translated. Persist stable item IDs such as `sword_iron_001`, never `res://...` paths.
- Never assume app version == save version.

## Before shipping

Implement backups appropriate to business value, crash simulations, and real device migration testing. Google Play Billing entitlements must be rechecked with Play and not inferred from writable local JSON. Protect personal data and avoid saving secrets in plain JSON. Cloud backup is **out of scope**.
