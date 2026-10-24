# Upgrade / refactor protocol

1. Create branch: `chore/upgrade-godot-4-7-x` or `chore/upgrade-admob`. Tag a known-good project revision and back up save fixtures.
2. Read official changelogs, migration guides and plugin Android SDK requirements. Record findings in `docs/dependencies.md`.
3. Update **ONE family** (engine OR AdMob OR Billing OR test plugin). Preserve API-facing gateway method names unless a breaking contract change is explicitly reviewed.
4. Audit GDScript parse/type errors, scene UID and resource references, Input Map, signal listeners, physics/collision changes, shaders and export preset changes.
5. Run `tools/validate_project.py`, Godot Editor import, headless tests, device APK smoke test, Android upgrade-over-install and signed release AAB internal testing (when SDK available).
6. If persistent schema changed: add incremental `SaveMigrator` step and fixtures. **Never rewrite historic fixtures** just to make tests green.
7. Document exact upgrade reason, Git commit, compatibility changes and remaining device verifications; only then merge.

**Refactor is not automatically an upgrade.** Avoid changing working feature logic or rewriting entire scenes solely because a new engine version exists. Template updates do not automatically apply to game repositories created from this template.
