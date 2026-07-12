# Ladders — Standard Implementation

Canonical vertical climb mechanic for **Gramps Don't Dance with the Devil**.  
All agents and level builders must use this path. Do **not** invent alternate ladder nodes.

## Canonical assets (only these)

| Role | Path |
|------|------|
| Scene | `scenes/platforms/ladder.tscn` |
| Zone logic | `scripts/platforms/ladder_zone.gd` (`LadderZone`) |
| Visuals | `scripts/platforms/ladder_visual.gd` (`LadderVisual`) |
| Player ability | `scripts/player/abilities/ladder_ability.gd` (`LadderAbility` on Player) |
| Spawn helper | `scripts/platforms/ladder_factory.gd` (`LadderFactory.spawn`) |

Player already has `LadderAbility` in `scenes/player/player.tscn`. Levels only place ladders.

## How to place a ladder (code)

```gdscript
# In any map builder / level script:
LadderFactory.spawn(objects_node, base_position, height_tiles)
```

- **`base_position`**: bottom-center of the ladder. Sit it on the platform/floor surface the player stands on.
- **`height_tiles`**: height in Kenney tiles (`KenneyPlatformTiles.TILE_SIZE` = 18px). Minimum 2. Typical: 8–22.
- Ladder grows **upward** from that base (top = `base.y - height_tiles * 18`).

### Examples

```gdscript
# 14-tile ladder on a platform surface at world pos
LadderFactory.spawn(_objects, Vector2(400.0, 720.0), 14)

# Short connector between two floors (~8 tiles ≈ 144px)
LadderFactory.spawn(_objects, floor_top_pos, 8)
```

### Editor placement

1. Instance `scenes/platforms/ladder.tscn` under your level `Objects` (or equivalent) node.
2. Set **Position** to the bottom-center on the landing platform.
3. Set exported **`height_tiles`** (and optionally `width_px` — default 38).

## Controls (player)

| Input | Action |
|-------|--------|
| **W / ↑** | Climb up / mount |
| **S / ↓** | Climb down / mount from above |
| **A / D** | Hover side-to-side on ladder; leave grip band → fall |
| **Space** | Jump off ladder |
| Hold **Space** while falling (not climbing) | Glide (unchanged) |

## Feel rules (do not break)

- Hold climb = steady speed (~260 px/s). Release = stop in place.
- No center rubber-band snap while climbing.
- Mount from ground with **W+A/D** must climb cleanly (mount grace + no bottom A/D walk-off while climbing up).
- Remount after side exit requires being near ladder center again (`mount_align_x`).
- Glide / crouch / wall only yield when climb intent is active near a ladder.

## Level design tips

- Leave a clear landing platform at the **top** (player pops up slightly on exit).
- Base should sit on solid ground/platform so bottom exit works.
- Prefer one ladder per vertical route; twins only for deliberate choice.
- Reference gauntlet: parkour map section **L** (`parkour_map_builder.gd` → `_build_ladder_section`).
- Shifting map spawn bay also has sample ladders via `LadderFactory`.

## Do NOT

- Create custom `Area2D` “ladders” with different scripts.
- Duplicate `_spawn_ladder` logic — call `LadderFactory.spawn`.
- Bind climb to Space / reuse jump for climb-up.
- Re-enable hard X snap-to-center every frame while mounted.

## Quick test checklist

1. Ground: **W** alone → climb up smoothly.
2. Ground: **W+A** / **W+D** → climb without flicker/snap loop.
3. Mid-ladder: release → hang; **A/D** hover; drift off edge → fall.
4. Top: hold **W** → step onto platform.
5. Bottom: **S** or walk **A/D** while idle on floor → leave.
6. **Space** mid-ladder → jump off.
7. Fall past ladder holding Space (no W/S) → glide still works.
