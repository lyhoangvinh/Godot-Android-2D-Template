# Architecture — Android-first Godot 2D

## Goals and non-goals

- **Goals:** readable file tree, simple authored scenes, typed GDScript, isolated persisted state, deterministic upgrade surface, tests, Android touch and lifecycle, offline gameplay, mockable AdMob/Billing boundaries.
- **Non-goals:** a clone of Android Clean Architecture/MVI/Hilt, game-wide service locator, universal RPG/crafting framework, PC-specific controls, multiplayer, Firebase, real commercial SDKs, unneeded abstractions.

## Ownership and dependency direction

```text
app/main.gd (COMPOSITION ROOT)
  -> Menu/MainMenu scene   -> Core/SaveRepository
  -> GameplayScreen scene  -> ArenaWorld -> Player/Enemy/Coin/HealthComponent
  -> MockAdsGateway       -> AdsGateway contract (no SDK)
  -> MockBillingGateway   -> BillingGateway contract (no SDK)

core/components / core/persistence / core/contracts: do not import features or Android SDK.
features: own scene graphs, gameplay state and UI. Access shared services only via injected contracts.
platform: implement contracts; may depend on external SDK, never reverse-depend on features.
app: constructs services, injects dependencies and handles navigation, not domain rules.
```

`Main` directly instantiates only feature entry scenes and stable gateways. It does not contain player logic, economy calculation or SDK callbacks.

## Why not copy Kotlin multi-module MVVM exactly?

Godot `Node` + `Scene` + `Signal` are composition primitives. Gameplay runs on engine callbacks (`_physics_process`, `_input`, `Area2D.body_entered`). Forcing every game action through ViewModel/UseCase/Repository adds ceremony and obscures the engine scene tree. Use plain classes/Resources for pure rules where valuable; use nodes for engine behavior; use signals for loose event delivery.

## File conventions

- `snake_case` for files, directories, and GDScript variables/functions; `PascalCase` for `class_name`; descriptive scene roots; consistent casing on Windows and Linux.
- Scenes hold view/entity wiring. `*.gd` holds behavior. `*.tres` holds reusable serialized data. Avoid hard-coded external paths; prefer Inspector references and stable UID when appropriate.
- Signal connections may appear in `.gd` or `.tscn`; search both during refactors. String NodePath references must be revalidated after renaming/moving nodes.
- Keep only reusable components in `core/`; first implementation can live entirely in a feature.
- Add Autoloads only when a cross-scene lifetime requirement justifies them. Current project intentionally has **zero Autoloads**.

## Current demo behavior

- `app/main.gd`: owns a `SaveRepository`, editor-only mock adapter instances and feature navigation.
- `features/menu`: start game, shows best/coins, toggles saved sound preference, **editor-only mock reward**.
- `features/gameplay/gameplay.gd`: HUD/pause/back/result; forwards input to `ArenaWorld`; commits progress once.
- `features/gameplay/arena_world.gd`: spawns 2 enemies + 3 coins, updates score, checks enemy damage and ends run. Uses Godot physics bodies and Area2D.
- `features/gameplay/player`: keyboard/joystick directional movement; `HealthComponent` receives damage and emits death.
- `core/persistence`: data access with two-stage validation/migration and recovery. No gameplay script accesses files directly.

## Data and revenue boundary

Gameplay never calls `Engine.get_singleton` to reach an AdMob plugin. Real SDK adapters must implement the interface in `core/contracts/`. Gameplay must not trust UI callbacks or local entitlement flags as purchase proof. Offerings, rewarded callbacks and product IDs belong in `platform/`, not the character/controller scripts. Production ads require UMP and version-tested SDK adapter; production billing requires Play integration and correct entitlement lifecycle.

## Android UI

Demo uses logical 720x1280 portrait canvas and GL Compatibility renderer. These defaults minimize casual 2D setup complexity, **not** guarantee every aspect ratio/device cutout. When building a new game: specify portrait or landscape, test window stretching, system bars/cutout, gesture area, back action, touch multi-pointer behavior, pause/resume, process recreation and orientation changes on physical devices.

## Stable extensions (when genuinely needed)

- A complex actor may gain `states/` FSM scripts; a two-state actor should not.
- An RPG may gain data-driven `Resource` catalogs under its feature, with stable content IDs and migration tests.
- A shop may add an `EconomyService`; **one single authority** for currency and prices.
- Android monetization may add a concrete plugin adapter under `platform/` and adapter integration tests, leaving `core/contracts/` stable.

## Review checklist

1. Is this a feature-local concern or truly cross-game reusable?
2. Can the existing scene/component represent it without creating another manager?
3. Are signals, node references and resource paths verifiably intact?
4. Does it change persisted IDs? If yes, add migration fixtures.
5. Does it need new Android permissions, plugin, privacy disclosure or Gradle/export changes?
6. Can static + Godot tests run? Are device checks and unresolved risks reported?
