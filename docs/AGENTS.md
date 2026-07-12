# Agent Instructions

For AI assistants (Cursor, Claude, etc.) working on **Gramps Don't Dance with the Devil**.

> **New clone?** Run the [First clone bootstrap](#first-clone-bootstrap) below before any feature work.

> **Scope freeze:** Session 1 = 2D platformer prototype (move/jump/double jump/obstacles). Read [GAME_DESIGN.md](GAME_DESIGN.md) before expanding scope.

## Project summary

- **Engine:** Godot 4.7-stable, 2D platformer
- **Style:** Level-based classics (Sonic / Mario / Mega Man) — long-term vision only
- **Current slice:** Movement prototype + `level_01` + documentation
- **Team:** 2 collaborators sharing one Git repo (technical lead + creative director)

## First clone bootstrap

**Trigger:** User cloned the repo, says "set up the project", or MCP/godot tools are unavailable.

Execute in order (project root):

```powershell
node --version          # need 20+
npm install             # installs @satelliteoflove/godot-mcp
```

Confirm these paths exist:

- `.cursor/mcp.json`
- `scripts/mcp/start-godot-mcp.cmd`
- `addons/godot_mcp/plugin.cfg`
- `package-lock.json`

Tell the user (manual steps you cannot do for them):

1. Install **Godot 4.7-stable** if missing
2. Open `project.godot` in Godot
3. **Project → Project Settings → Plugins** → **Godot MCP** enabled
4. MCP bottom panel shows listening on `127.0.0.1:6550`
5. Open this folder in **Cursor** → **Reload Window**
6. **Settings → MCP** → godot-mcp green, 21 tools

Then verify via MCP:

- `godot_project` → `get_info`
- `godot_project` → `addon_status` (versions should match)

If addon missing: `npm run mcp:install-addon` then restart Godot.

**Do not** add godot-mcp to the user's global `~/.cursor/mcp.json` — project-level config only.

Full human-readable steps: [SETUP.md](SETUP.md)

## Read first (every session)

1. [GAME_DESIGN.md](GAME_DESIGN.md) — vision vs current scope
2. [ARCHITECTURE.md](ARCHITECTURE.md) — folders, scenes, layers, input
3. [GITHUB_WORKFLOW.md](GITHUB_WORKFLOW.md) — branches, PRs, **never push to master** (creative director)
4. [COLLABORATION.md](COLLABORATION.md) — team roles
5. [SETUP.md](SETUP.md) — environment requirements
6. `.cursorrules` — GDScript conventions

## Git & PR rules (all agents)

> **Default branch:** `master` (not `main`). **Partner branch:** `jky`.

| Rule | Who |
|------|-----|
| Sync with latest code before starting work | Everyone |
| Work on **`jky` only** | JK (creative director) — required |
| Work on **`master`** (or feature branches if Ryan asks) | Ryan (lead developer) |
| **Never push to `master`** | JK's agent |
| **Never merge Pull Requests** | JK's agent — Ryan merges |
| **Never force-push `jky`** | All agents |
| **Never delete `jky`** | All agents — it is the partner's permanent branch |
| **Never `git commit` unless user explicitly asks** | All agents |
| Test with **F5** or Godot MCP before user commits / opens PR | All agents |
| PR base: **`master`**, compare: **`jky`** | JK opens PRs |
| PR description must include **what changed** and **how to test** | Whoever opens the PR |
| Read scope in GAME_DESIGN.md before adding features | All agents |

**JK sync ritual (before every work session):**

```powershell
git checkout jky
git pull origin jky
git fetch origin
git merge origin/master
```

After merging `master`, if levels need ladders read **[docs/LADDERS.md](LADDERS.md)** and spawn only via `LadderFactory.spawn` / `scenes/platforms/ladder.tscn`.

**Lead developer (Ryan):** may commit/merge to `master` after reviewing PRs. Still test before merge. Ryan does not work on `jky` unless reviewing JK's branch.

**JK (creative director) onboarding prompt:**

```
This is GramsBewareoftheDevil. Read docs/AGENTS.md, docs/GITHUB_WORKFLOW.md, docs/GAME_DESIGN.md, docs/LADDERS.md.
Work ONLY on the jky branch — never master. Do not create design/* or feature/* branches.
Before starting: git checkout jky, git pull origin jky, git fetch origin, git merge origin/master.
Ladders: ONLY use LadderFactory.spawn(parent, base_pos, height_tiles) or instance scenes/platforms/ladder.tscn.
Test in Godot (F5 or MCP) before I commit. Parkour section L and shifting spawn bay have reference ladders.
Never push to master or merge PRs — I open PRs (jky → master) for Ryan to review.
Never commit unless I explicitly say "commit".
```

## Executor / Advisor loop

| Role | Model | Does |
|------|-------|------|
| Executor | Composer 2.5 | Implements, runs commands, iterates |
| Advisor | Grok 4.5 | Plans architecture, verifies work |

**Non-trivial tasks:** Grok plans before coding. Grok verifies when user confirms.

## Godot MCP

- Godot editor must be **open** with **Godot MCP** plugin enabled
- MCP launches via `scripts/mcp/start-godot-mcp.cmd` (no hardcoded drive paths)
- Prefer MCP tools for scene inspection, playtesting, TileMap/GridMap edits
- Do not guess node paths — use `godot_node_read` / scene tree tools
- Script edits on disk: `stop` → `run` picks up changes (no editor restart for gameplay `.gd`)
- After `project.godot` edits: Godot editor restart may be needed for input map / autoloads

## Code conventions

- Typed GDScript everywhere
- `snake_case` files/functions, `PascalCase` nodes/classes
- `@export` tunables on movement params for designer iteration
- Composition over deep inheritance
- No game autoloads until multiple systems need them

## Safe extension order

1. Movement feel tweaks (`scripts/player/player.gd` exports)
2. More platforms/obstacles in `level_01` or `level_02`
3. TileMapLayer migration for level authoring
4. `EventBus` autoload when signals cross many scenes
5. Combat / items / story — only after user sign-off on prototype feel

## Do not

- Rewrite project structure without user request
- Add 3D systems (project uses 2D; Jolt is 3D-only config)
- Commit secrets, `.godot/`, `node_modules/`, or `builds/*.exe`
- Create git commits unless user explicitly asks
- Hardcode machine-specific paths in MCP config

## Key paths

| Path | Purpose |
|------|---------|
| `scenes/player/player.tscn` | Player prefab |
| `scripts/player/player.gd` | Movement logic |
| `scenes/levels/level_01.tscn` | Main / prototype level |
| `project.godot` | Input map, main scene, layers |
| `docs/SETUP.md` | Full onboarding for new machines |
| `docs/GITHUB_WORKFLOW.md` | Branches, PRs, review process |
| `docs/ASSETS.md` | Kenney placeholders, what is gitignored |
| `docs/LADDERS.md` | Standard ladder placement + feel rules (all agents) |
| `scripts/platforms/ladder_factory.gd` | `LadderFactory.spawn` — only way to spawn ladders in code |
| `scenes/platforms/ladder.tscn` | Ladder prefab |
| `assets/placeholders/kenney/` | Committed Kenney tiles + characters (partner gets via Git) |
| `scripts/mcp/start-godot-mcp.cmd` | Portable MCP launcher (Windows) |

## Verification checklist

- [ ] `npm install` completed
- [ ] Godot open, MCP plugin listening
- [ ] Cursor godot-mcp green, 21 tools
- [ ] Project runs without script errors (F5 or MCP run)
- [ ] Movement, hazard respawn, goal feedback work
- [ ] `assets/placeholders/kenney/tiles_packed.png` and `characters_packed.png` exist
- [ ] Docs updated if architecture or scope changed
