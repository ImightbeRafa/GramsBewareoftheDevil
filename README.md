# Gramps Don't Dance with the Devil

A 2D level-based platformer inspired by classic Sonic, Mario, and Mega Man — built in **Godot 4.7**.

## New to this repo?

**Start here:** [docs/SETUP.md](docs/SETUP.md) — full steps for Godot, Node, Cursor, and Godot MCP after `git clone`.

**Partner onboarding prompt** (paste into Cursor after clone):

```
I just cloned gramps-dont-dancewiththe-devil. Follow docs/SETUP.md step by step:
1) Run npm install
2) Walk me through Godot 4.7 setup and enabling the MCP plugin
3) Reload Cursor and verify godot-mcp is green with 21 tools
4) Run the game via MCP or tell me to press F5
Then read docs/AGENTS.md and docs/GAME_DESIGN.md so you understand project scope.
```

## Current scope (Session 1 prototype)

- Move, jump, double jump, navigate test level with platforms, hazards, and a goal
- Movement feel tuned for iteration (coyote time, jump buffer, variable jump height)
- Foundation scenes and folder structure for future systems

**Not in scope yet:** combat, items, story, menus, special levels, TileMap levels.

## Requirements

- [Godot 4.7-stable](https://godotengine.org/download)
- [Node.js 20+](https://nodejs.org) (for Godot MCP in Cursor)
- [Cursor](https://cursor.com) (optional but recommended for AI-assisted dev)
- Windows (current export target)

## Quick start (after setup)

```powershell
git clone <YOUR_REPO_URL>
cd gramps-dont-dancewiththe-devil
npm install
```

1. Open `project.godot` in Godot 4.7 → enable **Godot MCP** plugin if needed
2. Open this folder in Cursor → reload window → confirm MCP green
3. Press **F5** in Godot — main scene: `scenes/levels/level_01.tscn`

### Controls

| Action | Keys |
|--------|------|
| Move left | A / Left Arrow |
| Move right | D / Right Arrow |
| Jump | Space / W / Up Arrow (double jump in air) |

## Documentation

| Doc | Purpose |
|-----|---------|
| [docs/SETUP.md](docs/SETUP.md) | **Full onboarding** — clone to ready (humans + AI) |
| [docs/GAME_DESIGN.md](docs/GAME_DESIGN.md) | Vision, scope, what comes later |
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | Folders, scenes, physics layers, input |
| [docs/COLLABORATION.md](docs/COLLABORATION.md) | Git workflow for two collaborators |
| [docs/AGENTS.md](docs/AGENTS.md) | Instructions for AI agents |

## AI development

- **Godot MCP** — editor bridge; Godot must be open
- **`.cursor/mcp.json`** — portable MCP config (no per-machine paths)
- **`.cursorrules`** — Godot 4 GDScript standards

Keep Godot open while Cursor agents edit scenes or run playtests.
