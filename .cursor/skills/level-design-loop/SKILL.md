---
name: level-design-loop
description: >-
  Iterative Godot 2D platformer level design for Gramps — pairing environment
  with movement/cane abilities, shifting-map beats, playtest-verify loops.
  Use when designing or rebuilding levels, parkour routes, shifting bays,
  ability gates, or when the user asks to improve level design, UX flow, or
  run a design-verify loop.
---

# Level Design Loop (Gramps / Godot 4.7)

## Goal

Ship levels where **environment teaches and tests abilities together** — not isolated mechanic boxes. Every bay should have a readable verb (dash gap, wall climb, pogo chain, hook swing, smash gate) reinforced by hazards, timing, and shifting geometry.

## Core loop (repeat until fun)

```
Design beat → Build in builder/scene → Playtest → Log in todo.md → Adjust
```

1. **Pick one ability pair** for the beat (e.g. dash + shift warning, hook + moving fire orb).
2. **Sketch 4 layout poses** per shifting block (low / mid / high / alternate route).
3. **Place safe island first**, then hazard void, then shifting fill — never overlap hazard stacks.
4. **Playtest full route** spawn → goal on all 4 global layouts (A–D).
5. **Record** in `todo.md` Verify log: PASS/FAIL + one-line note.
6. **Fix** only what playtest proved wrong; avoid speculative decoration.

## Shifting map rules

| Rule | Target |
|------|--------|
| Shift cadence | 8s stable · 1s warning · 1s shift |
| Safe islands | Solid tile ground + checkpoint; reachable without shifting blocks during WARNING |
| Shifting blocks | 2+ per bay; pose delta ≥ 4 tiles vertically or ≥ 6 horizontally |
| Untouchable phase | Blocks **hidden** (no ghost collision, no semi-visible ledges) |
| Freeze anchors | Near decision points; unfreeze resumes timer at ~50% |
| Exit triggers | Nudge timer (~45%), don't instant-force shift |

## Bay template (160×96 reference)

Each bay between safe islands:

1. **Read** — player sees goal island and one obvious hazard (pit, orb, toxic).
2. **Choice** — safe slow path vs skill path (crumble, mover, hook ceiling).
3. **Exam** — one ability must be used correctly once; second use is optional mastery.
4. **Rest** — checkpoint island with freeze crystal before next bay.

Ability pairing cheat sheet:

| Bay theme | Primary | Secondary | Environment hook |
|-----------|---------|-----------|------------------|
| 0 Bridge | Dash / run jump | Pogo off pad | Wide gap + shifting bridge |
| 1 Shelf | Wall jump | Pogo down-cone | Toxic pit, side hooks |
| 2 Pillar | Hook swing | Glide / dash | Fire orb lane, tall pillar |
| 3 Finale | Smash gate | Hook chain | Crumble blocks + shifting ledge |

## Collision & UX hygiene (check every build)

- Hook points: `Node2D` only — **never** solid collision on hook markers.
- Pogo: must work on tiles, static platforms, touchable shifting blocks.
- Hazards: one primary threat per pit column range; no spike+toxic+trap same X band.
- UI: compact HUD; contextual hints ≤ 2.5s; no large tutorial panels in world.
- Cane: Q cycles unlocked modes; LMB/J uses active mode with mouse aim.

## Playtest checklist (copy to todo.md)

- [ ] Q → Pogo / Hook / Smash; HUD chip matches
- [ ] Pogo: mouse down-cone, bounce on terrain, no infinite bounce iframe
- [ ] Hook: aim select, pull, swing line visible, release jump boost
- [ ] Smash: mouse aim breaks crumble gate at goal
- [ ] No invisible bumps spawn → goal
- [ ] WARNING: can reach safe island from every bay on all layouts
- [ ] SHIFTING: falling through hidden blocks feels fair (player had warning)
- [ ] Full run under 3–5 min skilled, 8–12 min learning

## Godot MCP / runtime verification

When Godot editor + MCP bridge is connected:

1. Load `scenes/levels/shifting_map.tscn` (SceneRouter: **O**).
2. Screenshot + runtime state after 30s of play.
3. Inspect player position, layout index, shift state.
4. Log failures with layout index + bay number.

If MCP unavailable: code review + manual playtest in editor; mark verify log PENDING.

## File map

| Concern | File |
|---------|------|
| Map geometry | `scripts/levels/shifting_map_builder.gd` |
| Shift timing | `scripts/levels/shifting_map_controller.gd` |
| Task tracking | `todo.md` |
| HUD | `scripts/ui/parkour_hud.gd`, `cane_mode_hud.gd`, `shifting_map_hints.gd` |
| Cane | `scripts/player/abilities/cane_*.gd` |

## When expanding a bay

Add **function** before **size**:

1. New route using an underused ability.
2. One shifting block pose that opens a route closed in other layouts.
3. Optional collectible or faster line — not required for completion.

Avoid: single-block bays, ±2 tile pose tweaks, decorative hooks with no line, hazard piles in the same pit.
