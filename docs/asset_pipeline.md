# Assets / animation contract for AI-generated games

No external art is bundled in this starter. The demo renders shapes via `Node2D._draw()`. Before adding real sprites, define a content import contract per game:

- **Authoritative source** in `features/<feature>/assets/source/` as PNG/SVG/etc. For pixel art use lossless PNG; decide filtering & mipmaps deliberately.
- A sprite atlas MUST declare dimensions, cell size, frame count, pivot/origin, playback FPS, names, state transitions, directional facing, hitboxes and expected animations. Do not assume AI-generated sprite sheets obey a grid until programmatically inspected and visually reviewed.
- Never replace old assets blindly; maintain stable logical IDs so save data does not depend on art filenames.
- Add third-party license + attribution where required. Keep generated assets, source and import settings version controlled, not editor cache `.godot/`.
- Validate scale drift, halos, transparency, frame boundaries and clipping before implementing runtime animation.
- Check draw calls, texture count, compression and memory on low-end Android devices; profile on hardware.
- Establish naming conventions in `docs/architecture.md` for each game-specific asset pack. Avoid dumping files into `res://assets/` without ownership.
