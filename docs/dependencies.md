# Pinned dependencies and upgrade record

| Component | Current pin | Installation / status |
|---|---|---|
| Godot editor | **4.7.2 stable, Standard** | Required; download directly from godotengine.org |
| Godot export templates | **4.7.2** | Required for APK/AAB; not bundled |
| GDScript | Built into Godot 4.7.2 | Typed, no external runtime |
| Renderer | GL Compatibility | Chosen for broadly accessible Android 2D |
| Python (static checker) | >= 3.9 | Optional host development tool |
| Godot regression tests | Dependency-free `SceneTree` runner | Included in tests/ |
| AdMob | Not installed | Stub contract + editor-only mock only |
| UMP | Not installed | Required integration if applicable before ads |
| Play Billing | Not installed | Stub contract + disabled mock only |
| Android SDK/Gradle | Not installed into ZIP | Configure on local Windows machine |
| Art/audio external assets | None | Procedural placeholder graphics only |

**Upgrade policy:** One dependency family per branch; never blindly update all plugins. Pin exact Godot and native plugin versions and run migration + Godot + Android regression tests. Record package, plugin revision, license, reason, SDK changes and rollback plan. See [Upgrade policy](upgrade_policy.md).

Reference: https://godotengine.org/download/archive/4.7.2-stable/ and https://docs.godotengine.org/en/4.7/tutorials/export/exporting_for_android.html
