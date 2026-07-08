# Assets Guide

Where art lives, what gets committed, and what your partner needs after `git clone`.

## Kenney Pixel Platformer (current placeholder art)

**Location:** `assets/placeholders/kenney/`

| File | Purpose |
|------|---------|
| `tiles_packed.png` | TileMap terrain (used by `KenneyPlatformTiles`) |
| `characters_packed.png` | Player + enemy sprite sheets |
| `kenney_pixel-platformer.zip` | Original download archive (backup) |
| `*.png.import` | Godot import metadata — **committed** so both machines import the same way |

**License:** CC0 — [Kenney Pixel Platformer](https://kenney.nl/assets/pixel-platformer). See `assets/placeholders/kenney/README.md`.

**Code that uses these:**

- `scripts/levels/kenney_platform_tiles.gd` — builds TileSet from `tiles_packed.png`
- `assets/sprite_frames/player_frames.tres` — player animations
- `assets/sprite_frames/enemy_frames.tres` — enemy animations

### Partner setup (automatic)

**No extra download.** After `git clone` + `git pull`, the PNGs are already in the repo.

1. Open `project.godot` in Godot 4.7
2. Godot may reimport textures on first open (normal — wait for progress bar)
3. Press **F5** — tiles and characters should appear

If sprites look wrong or pink/missing:

- **Project → Reload Current Project**
- Confirm `assets/placeholders/kenney/tiles_packed.png` exists on disk
- Check Output panel for import errors

### Cursor agent (partner)

After clone, agent should **not** clone `_tmp_pixel_platformer` or any external asset repo. Assets are already under `assets/placeholders/kenney/`. Verify with:

```powershell
Test-Path assets/placeholders/kenney/tiles_packed.png
Test-Path assets/placeholders/kenney/characters_packed.png
```

Both should be `True`.

---

## What is `_tmp_pixel_platformer/`?

A **local reference folder** — cloned Kenney/uheartbeast tutorial project used while integrating art. It is **gitignored** and **not shared**.

| | `_tmp_pixel_platformer/` | `assets/placeholders/kenney/` |
|--|--------------------------|-------------------------------|
| In Git? | ❌ No (gitignored) | ✅ Yes |
| Partner needs it? | ❌ No | ✅ Yes — comes with clone |
| Safe to delete locally? | ✅ Yes, after assets integrated | ❌ No — game uses these files |

**Why Git warned you:** `_tmp_pixel_platformer` contains its own `.git` folder. Git tried to add it as a nested repo (empty pointer), not the actual files. Fix: gitignore the folder; commit only `assets/placeholders/kenney/`.

---

## Future custom art

When you replace placeholders:

1. Put new art in `assets/custom/` (create when ready)
2. Update sprite frames / tileset scripts to point there
3. Keep Kenney files until swap is complete, or remove in a dedicated PR

---

## What not to commit

| Path | Reason |
|------|--------|
| `_tmp_pixel_platformer/` | Local reference clone with nested `.git` |
| `.godot/` | Editor cache (rebuilt per machine) |
| `node_modules/` | Run `npm install` after clone |

Already in `.gitignore`.
