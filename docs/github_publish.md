# GitHub publish and game creation

## Publish the template (one time)

1. Test the Godot import and demo on Windows first. Commit `.gd.uid` files if the editor creates them; never commit `.godot/` cache.
2. Create an **empty GitHub repository** named e.g. `Godot-Android-2D-Template`. Do not generate an extra README or license on GitHub (the ZIP already contains both).
3. From the extracted source directory:

```powershell
git init
git branch -M main
git add .
git commit -m "feat: initial Godot Android 2D base template"
git remote add origin https://github.com/lyhoangvinh/Godot-Android-2D-Template.git
git push -u origin main
```

4. On GitHub → **Settings → General → Template repository**. After local tests pass, tag the audited revision:

```powershell
git tag v1.0.0
git push origin v1.0.0
```

5. A new game should start via **Use this template → Create a new repository**. Set its title in `project.godot`, create a unique Android application/package ID in its own **local** export preset, and create/upload a separate key. Keep game-specific assets and business logic out of the base template.

## Why no GitHub Actions workflow was bundled?

A workflow requires a GitHub credential authorized to create `.github/workflows` files. If an OAuth Git client lacks `workflow` scope, pushes may be refused. The template instead provides local `tools/validate_project.py` and `tools/test_godot.ps1`. You may set up CI later with an approved GitHub identity, pinned runner and Godot 4.7.2 binary. Do not mark CI configured when it is not.

## Deliverables for Claude / ChatGPT

Supply the exact template release/tag/commit and current game ZIP or repository state. If Claude cannot fetch GitHub in its sandbox, **attach the source ZIP as well**. Keep source of truth in the game's repo, never in conversation history alone.
