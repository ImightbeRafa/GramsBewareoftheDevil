# Gramps Don't Dance with the Devil

A 2D level-based platformer inspired by classic Sonic, Mario, and Mega Man — built in **Godot 4.7**.

## New to this repo?

**Start here:** [docs/SETUP.md](docs/SETUP.md) — full steps for Godot, Node, Cursor, and Godot MCP after `git clone`.

**Partner onboarding prompt** (paste into Cursor after clone):

```
I just cloned GramsBewareoftheDevil. Follow docs/SETUP.md step by step:
1) Run npm install
2) Verify assets/placeholders/kenney/ has tiles_packed.png and characters_packed.png (docs/ASSETS.md)
3) Walk me through Godot 4.7 setup and enabling the MCP plugin
4) Reload Cursor and verify godot-mcp is green with 21 tools
5) Run the game via MCP or tell me to press F5
Then read docs/AGENTS.md, docs/GAME_DESIGN.md, and docs/GITHUB_WORKFLOW.md.
Do NOT clone or use _tmp_pixel_platformer — it is gitignored; art is already in assets/placeholders/kenney/.
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
git clone https://github.com/ImightbeRafa/GramsBewareoftheDevil.git
cd GramsBewareoftheDevil
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
| [docs/GITHUB_WORKFLOW.md](docs/GITHUB_WORKFLOW.md) | **Branches & Pull Requests** — how to collaborate on GitHub |
| [docs/ASSETS.md](docs/ASSETS.md) | Kenney art — what partners get from Git |
| [docs/FOR_LEAD_DEVELOPER.md](docs/FOR_LEAD_DEVELOPER.md) | Lead dev guide — review PRs, explain to partner |
| [docs/GAME_DESIGN.md](docs/GAME_DESIGN.md) | Vision, scope, what comes later |
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | Folders, scenes, physics layers, input |
| [docs/COLLABORATION.md](docs/COLLABORATION.md) | Git workflow for two collaborators |
| [docs/AGENTS.md](docs/AGENTS.md) | Instructions for AI agents |

## AI development

- **Godot MCP** — editor bridge; Godot must be open
- **`.cursor/mcp.json`** — portable MCP config (no per-machine paths)
- **`.cursorrules`** — Godot 4 GDScript standards

Keep Godot open while Cursor agents edit scenes or run playtests.
