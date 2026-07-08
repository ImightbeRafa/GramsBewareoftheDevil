# Architecture

Godot **4.7** · 2D platformer · default Godot 2D physics (Jolt is 3D-only in this project).

## Folder layout

```
res://
  scenes/
    player/          player.tscn — CharacterBody2D, camera, collision
    levels/          level_01.tscn — prototype level (main scene)
  scripts/
    player/          player.gd — movement, respawn
    hazards/         hazard_zone.gd — respawn trigger
    levels/          goal_zone.gd — level clear feedback
  assets/
    placeholders/    (reserved for art swaps)
  docs/              human + AI documentation
  builds/            exported playtest builds (gitignored)
  addons/godot_mcp/  MCP editor bridge (do not edit casually)
```

## Scenes

| Scene | Root type | Owns |
|-------|-----------|------|
| `scenes/player/player.tscn` | `CharacterBody2D` | Movement, camera, collision shape, placeholder visual |
| `scenes/levels/level_01.tscn` | `Node2D` | Platforms, hazards, spawn, goal, UI label, player instance |

### Level tree

```
Level01 (Node2D)
├── Background (ColorRect)
├── Platforms (Node2D)
│   └── StaticBody2D children (world collision)
├── Hazards (Node2D)
│   └── Area2D + hazard_zone.gd
├── SpawnPoint (Marker2D, group: spawn_point)
├── Player (instance of player.tscn)
├── Goal (Area2D + goal_zone.gd)
└── UI (CanvasLayer)
    └── GoalLabel (Label, group: goal_feedback)
```

## Physics layers (2D)

| Layer | Name | Used by |
|-------|------|---------|
| 1 | `world` | StaticBody2D platforms |
| 2 | `player` | Player CharacterBody2D |
| 3 | `hazard` | Hazard Area2D |
| 4 | `goal` | Goal Area2D |

Player `collision_layer = 2`, `collision_mask = 1` (world only). Hazards/goals use `Area2D` monitoring — no physics layer collision required for prototype.

## Input map

| Action | Bindings |
|--------|----------|
| `move_left` | A, Left |
| `move_right` | D, Right |
| `jump` | Space, W, Up |

## Autoloads

| Name | Purpose |
|------|---------|
| `MCPGameBridge` | Godot MCP tooling only |

**No game autoloads yet.** Defer `EventBus` / `Game` until multiple systems need global signals.

## Extension points

- **New levels:** duplicate `level_01.tscn` pattern under `scenes/levels/`
- **New hazards:** Area2D + script, or extend `hazard_zone.gd`
- **Art swap:** replace `ColorRect` visuals; keep `CollisionShape2D` sizes stable
- **TileMap:** migrate `Platforms` to `TileMapLayer` in Session 2+

## Display

- Target viewport: **1280×720**
- Stretch: `canvas_items`, aspect `expand`

## Main scene

`res://scenes/levels/level_01.tscn`
