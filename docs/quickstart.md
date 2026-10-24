# Quick Start (English)

## Open the project

1. Install **Godot 4.7.2 Standard** for Windows. The .NET/C# edition is not required.
2. Extract the project ZIP and open `project.godot` in Godot Project Manager.
3. Press **F5** to launch the top-down demo. Move using **WASD/arrow keys** or the bottom-left virtual joystick, collect yellow coins, and avoid pink enemies.
4. Explore `features/` one feature at a time. The entry point is `app/main.gd`, gameplay is coordinated by `features/gameplay/arena_world.gd`, and persistent data lives in `core/persistence/`.
5. Run `python tools/validate_project.py`, then `tools/test_godot.ps1` as described in the README.

## Important limitations

- **This is not a finished commercial game.** Real AdMob and Google Play Billing are **not integrated**. Mock monetization is for Editor testing only and must never be treated as production-ready.
- **No signing keystore is included.** Create a per-game upload key in Android Studio and store it outside the repository. Each game must have its own Android application ID and export configuration.
- Save files use the `user://` directory and a versioned JSON v2 schema with v1 migration and backup behavior. Any persistent data changes must include migration tests.
- Start a new game with GitHub's **Use this template** option or a previously tested copy, and record the starting tag/commit in the new game's README.
- Template updates do not automatically propagate into projects created from it. Use a dedicated upgrade branch and run tests before merging.

## Essential Godot concepts

- `Node`: a unit of behavior; `Scene (.tscn)`: a reusable collection of nodes.
- `Script (.gd)`: GDScript attached to a node; `Resource (.tres)`: reusable data; `Signal`: an event communication mechanism.
- `SceneTree`: the runtime node hierarchy, not the filesystem or Git tree.
- `_ready`, `_process`, and `_physics_process`: common engine lifecycle/update callbacks.
- `Area2D`, `CharacterBody2D`, `CollisionShape2D`, Input Map, and `CanvasLayer`: fundamental 2D gameplay tools.

## After successful local verification

Commit your source and any `.gd.uid` files Godot generates. Do not commit the `.godot/` import cache. To export an Android AAB, configure the Android SDK, Godot export templates, and the Gradle Build Template as described in `docs/android_release.md`.
