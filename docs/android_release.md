# Android development, signing, AAB — Windows

**This starter DOES NOT include preinstalled Android build template, export templates, Java/Kotlin SDK plugins, keystore or production keys.** Prepare these on your Windows machine with the same Godot **4.7.2** engine you use to open the project.

## Prerequisites

1. Install JDK and Android SDK/build tools per the matching [Godot 4.7 Android docs](https://docs.godotengine.org/en/4.7/tutorials/export/exporting_for_android.html). Android Studio is a convenient Android SDK/JDK management option.
2. In Godot Editor settings, point to the SDK and JDK paths and install **Godot 4.7.2 export templates** (version must match).
3. Project → Install Android Build Template (needed for custom Gradle build / AAB / most Android plugins). Review and retain generated `android/` files only if necessary for the project.
4. Project → Export → Add Android preset. Set **package name**, icon, version code and versions according to your specific game. **Never ship the template placeholder package**.
5. Enable Gradle Build. Use debug APK to test and a non-debug signed AAB for Google Play. Android's `versionCode` must increase for updates.

## Keystore

A release JKS created with **Android Studio** works for Godot. File extension is not what makes it a keystore. Use a unique upload key for each production game, store it outside Git and the AI ZIP, make secure backups. Configure keystore path, alias and password in local Export Preset or inject signing environment variables:

```powershell
$env:GODOT_ANDROID_KEYSTORE_RELEASE_PATH = 'D:\AndroidSigning\Game-upload.jks'
$env:GODOT_ANDROID_KEYSTORE_RELEASE_USER = 'game_upload'
$env:GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD = '<your-local-secret>'
```

Do not paste real passwords into chat, GitHub, README, script or CI logs. The Godot docs state current release keystore and key password need to match. Godot signs the uploaded AAB with your upload key; **Google Play App Signing** signs distributed APKs with the app-signing key.

`export_presets.cfg` is **intentionally gitignored** because it can contain secrets/user-machine paths. Keep a sanitized export setup walkthrough, and if automation is later required, use CI secrets and a reviewed, secret-free preset template.

## Ads and in-app purchases

`MockAdsGateway` can signal rewards only when `OS.has_feature("editor")` (not in export). The mock reward button is hidden from exported builds. `MockBillingGateway` is fake, disabled by default, and cannot succeed outside editor. This is NOT a working AdMob or billing integration.

Before releasing a monetized game:

- Pick a plugin compatible with the **exact Godot version** and pin its repository/tag/commit plus license. Prefer maintained Android plugin v2 implementations.
- Audit Play Billing / Google Mobile Ads SDK requirements and transitive native dependencies, including modern Android page-size requirements, target SDK, proguard/R8 where relevant.
- Implement real `AdsGateway` and `BillingGateway` adapters, ad lifecycle/loading/retries, rewarded callback verification, UMP/privacy flow before ad requests, purchase acknowledgment/consume/restore/entitlements and failure handling.
- Test Play Billing with Google Play internal testing and licensed test accounts. A locally sideloaded debug APK is not a substitute for Play Billing testing.
- Put all production app IDs/product IDs in game-specific config, never in the reusable template.
- Audit policy declarations and Data Safety before Google Play rollout.

## Minimum acceptance gates

- [ ] Godot Editor imports project without parse errors.
- [ ] Headless tests pass on pinned engine.
- [ ] Local debug APK starts, receives multi-touch, returns to foreground correctly, never plays audio after exit.
- [ ] Saves survive app process death and an **upgrade-over-install** of the same package/signing key.
- [ ] Real device test across at least low-end and modern Android resolution/OS; cutouts, status/gesture/nav inset behavior, landscape if applicable.
- [ ] AAB built with release signing, uploaded to Play internal test track.
- [ ] AdMob/UMP/IAP tested on devices and Play test track if monetized.
- [ ] Native dependencies checked for 16 KB memory page device compatibility as applicable.
- [ ] Version code/package, product IDs, privacy and store listing are correct.

Do not mark this template release-ready merely because the Godot demo runs on Windows.
