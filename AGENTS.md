# AI development contract — Godot Android 2D Template

Read before ANY code change. Applies to Claude, Codex, ChatGPT, and other coding agents.

**Mandatory language policy:** All repository content must be written in English only, including source code, comments, identifiers, scene/node names, UI strings, documentation, filenames, prompts, tool-generated reports, and commit messages. Never include Vietnamese in the project. Communicate with the project owner outside the repository in their preferred chat language if necessary.

1. **Starting point:** use this exact source tree and pinned Godot **4.7.2 Standard**. Do not regenerate the project from scratch, silently upgrade the engine/plugins or add .NET/C#.
2. **Architecture:** features under `features/<name>/`; reusable engine-agnostic rules in `core/`; adapters in `platform/`; app composition in `app/`. Prefer scene composition and signals over globals. No unbounded Managers/God Objects. No circular feature dependencies.
3. **Godot scene constraints:** keep `.tscn`, `.tres`, `.gd`, stable resource identifiers and references in sync; check signal wiring, node paths, input actions and renderer. Edit resources with Godot Editor when possible. Don't bulk rename nodes outside the Editor without full reference search.
4. **Data contract:** never rename/delete persistent fields or item IDs without versioned `SaveMigrator` migrations, fixtures and regression tests. Never silently default a corrupt or future save and overwrite it. Never use file paths or display names as persistent item identity.
5. **Android contract:** gameplay runs offline; no network requirement for core play. All ad/reward and billing operations go through a gateway. Never grant a rewarded outcome on ad close or show: only verified reward callbacks. Never trust locally cached premium as proof of purchase. Respect consent, lifecycle and process death.
6. **Build/security:** NEVER place a keystore, password, production AdMob ID, signing secret or private key in this repo/ZIP. Don't enable real ads or IAP via placeholders. Production release requires explicit SDK integration and device verification.
7. **Quality:** typed GDScript, snake_case paths, PascalCase class_name, explicit signals, minimal public API, no speculative refactor or unused folders. If a script gets too large, split by responsibility (not arbitrary line count). Never change already-working code only for aesthetic reasons.
8. **Tests:** run `python tools/validate_project.py`; run Godot `--editor --import` and `tests/test_runner.gd` if executable available. A passed static audit IS NOT a passed Godot build. Report exact tested/untested commands, tool versions and failures.
9. **Handoff:** submit complete Godot source ZIP **excluding** `.godot/`, `*.jks`, `*.apk`, `*.aab`, passwords and unrelated media. Keep `project.godot`, all scenes, Resources, scripts, fixtures, docs and plugin dependencies required for reproducibility. Deliver changed-files list, architecture impact, save migration notes and device tests still required.
10. **Progress over bulk rewrites:** work on the latest accepted commit, not a stale zip. Ask for assets if required; never pretend placeholder animation/combat/monetization is production-ready.

## Feature creation checklist

- Purpose and owned state documented in `docs/architecture.md` if material.
- Scene script in the feature directory; resources near their owner.
- Expose only signals/methods needed by callers.
- No direct reference from core/domain code into concrete UI or Android plugins.
- Update test fixtures for any data/schema change.
- Update `docs/dependencies.md` if plugin/runtime version changes.
- Keep the playable demo and old features operational.

## Handoff report template

```text
Engine & exact version:
Base template release/tag/commit:
Changed files:
Added runtime dependencies and licenses:
Save schema change? migration and fixture:
Static audit: PASS/FAIL/NOT RUN + command
Godot Editor import: PASS/FAIL/NOT RUN + command
Headless tests: PASS/FAIL/NOT RUN + command
Android physical device: PASS/FAIL/NOT RUN
APK/AAB Release + signing: PASS/FAIL/NOT RUN
Known issues and follow-up:
```
