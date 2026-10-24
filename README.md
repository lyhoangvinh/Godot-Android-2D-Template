# Godot Android 2D Template

**Version:** 1.0.0-template  
**Pinned editor:** **Godot 4.7.2 Standard**, **typed GDScript**, GL Compatibility renderer  
**Target:** small, offline-first, portrait Android 2D games; Windows authoring; GitHub template repository  
**Status:** code and static checks supplied; **Godot editor/headless + Android APK/AAB tests are NOT verified in the authoring environment** (see [Validation](docs/validation.md)).

> This is a **playable architectural starter**, not a finished monetized game. It has **NO real AdMob SDK, UMP, Play Billing, Android Gradle template, production purchase verification, signing key, or store-ready AAB**. Mocks are intentionally editor-only. Do not ship it as a commercial build until those components are installed and tested on Android.

## Quick start (Windows)

1. Install [Godot **4.7.2 Standard**](https://godotengine.org/download/archive/4.7.2-stable/) and open `project.godot` via the Godot Project Manager. Do not use the .NET edition.
2. Click **Play (F5)**. The default portrait mini-game opens. `PLAY DEMO`: collect yellow coins, avoid pink chasers, drag the bottom-left joystick (or use **WASD/arrow keys**). Score and coins are saved when the run ends or you return to menu.
3. In PowerShell: `python tools/validate_project.py`; then `./tools/test_godot.ps1 -Godot "C:\path\to\Godot_v4.7.2-stable_win64.exe"`.
4. Follow [Android export](docs/android_release.md) to set up Android SDK, Godot export templates, Gradle, signing and AAB. Test device lifecycle and updates before release.
5. Use **Use this template** on GitHub for each new game. Pin the starting template version/commit in your new game's README.

**First lesson:** open `app/main.tscn`, `features/menu/main_menu.tscn`, `features/gameplay/gameplay.tscn` and `features/gameplay/arena_world.tscn` in the Editor. Inspect how scenes compose, scripts attach, and signals connect.

## What it includes

- **No singleton god-objects.** `app/main.gd` is a small composition root and router; each gameplay feature owns its state.
- **Feature-first source** under `features/`, reusable components under `core/`, optional Android SDK boundaries under `platform/`, UI styles under `shared/`.
- **Playable portrait demo**, lightweight procedural graphics (no third-party art licenses), physics body, mobile joystick, enemy, coin pickup, pause/background pause and run recording.
- **Versioned local persistence**, schema v1 → v2 migrator, validation, temp-file commit and best-effort backup recovery. Unknown versions fail closed/read-only, not silent overwrite.
- **AdsGateway/BillingGateway interfaces** and **clearly labeled editor-only mocks**. `platform/` adapters for real SDKs are a future integration task, not faked production implementations.
- **Dependency-free Godot regression test runner** with fixture data, `tools/validate_project.py` static checker and optional Windows PowerShell validation wrapper.
- Architecture, AI contract, data migration, release, asset rules and upgrade notes under `docs/`.

## Layout

```text
app/                # app boot + screen composition
core/components/    # reusable scene behavior: health
core/contracts/     # stable adapter contracts: ads, billing
core/persistence/   # save repository, validator, migrations
features/menu/      # menu scene, script
features/gameplay/  # arena, player, enemies, coin and joystick
platform/ads/       # editor mock; Android adapter not installed
platform/billing/   # editor mock; Android adapter not installed
shared/ui/          # centralized simple reusable UI styling
tests/              # headless test runner + historical save fixtures
tools/              # static audit and PowerShell test wrapper
docs/               # architecture, AI rules, release and change policy
```

## Operating rules

Read [AGENTS.md](AGENTS.md) and [Architecture](docs/architecture.md) before asking Claude/Codex to modify this template. Do not invent `GlobalManager`/`UtilManager` types, access SDKs from gameplay scripts, make speculative refactors, change persistent IDs without migrations, or add plugins without version pinning and licensing checks. Keep reusable code minimal; only add a feature when the game needs it.

## Monetization is deliberately not preinstalled

An AdMob plugin's compatibility, UMP consent behavior, and Play Billing version need testing *for the pinned engine and your game*. The template exposes stable contracts but includes **no Google dependencies**. See [Android release](docs/android_release.md) and [Dependencies](docs/dependencies.md).

## Source + license

Starter code: MIT (see [LICENSE](LICENSE)). Godot and any future third-party plugins/assets have their own licenses; review those independently. Customize copyright/license before publishing if desired.

## Tình trạng kiểm thử (VI)

Đã tạo project và bộ kiểm tra source tĩnh. **Chưa thể khẳng định mở Scene, chạy demo trong Godot hay xuất Android AAB thành công tại môi trường tạo ZIP**, vì ở đây chưa có Godot executable, Android SDK, export templates và thiết bị thật. Bạn cần chạy `tools/test_godot.ps1` và kiểm thử trên Android trước khi đánh dấu release-ready. Xem `docs/validation.md`.
