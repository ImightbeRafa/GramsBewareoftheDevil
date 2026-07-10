# Full Setup Guide

Complete onboarding for **both collaborators** after cloning from Git. Written for humans and **Cursor AI agents** — an agent can run most steps automatically; manual steps are called out clearly.

---

## Prerequisites (install once per machine)

| Tool | Version | Download |
|------|---------|----------|
| **Godot** | **4.7-stable** (exact) | https://godotengine.org/download |
| **Node.js** | 20+ | https://nodejs.org |
| **Git** | any recent | https://git-scm.com |
| **Cursor** | latest | https://cursor.com |

> Both teammates must use the **same Godot version** (4.7-stable). Mismatches cause project upgrade prompts and broken exports.

---

## Step 1 — Clone the repository

```powershell
git clone https://github.com/ImightbeRafa/GramsBewareoftheDevil.git
cd GramsBewareoftheDevil
```

> **JK:** After clone you land on `master`. Switch to your workspace branch: `git checkout jky` (Ryan must have created and pushed `jky` first — see [GITHUB_WORKFLOW.md](GITHUB_WORKFLOW.md)).

> **Daily Git workflow (branches + Pull Requests):** see [GITHUB_WORKFLOW.md](GITHUB_WORKFLOW.md)

---

## Step 2 — Install Node dependencies (MCP server)

From the **project root**:

```powershell
npm install
```

This installs `@satelliteoflove/godot-mcp` locally (pinned in `package-lock.json`). Required for Cursor's Godot MCP bridge.

**Verify:**

```powershell
npm run mcp -- --version
```

Should print a version (e.g. `4.1.0`). Press Ctrl+C if it starts the server instead — or use:

```powershell
node node_modules/@satelliteoflove/godot-mcp/dist/cli.js --version
```

---

## Step 2b — Verify placeholder art (included in Git)

Kenney sprites and tiles are already in the repo — **no extra download**:

```powershell
Test-Path assets/placeholders/kenney/tiles_packed.png
Test-Path assets/placeholders/kenney/characters_packed.png
```

Both should return `True`. Full details: [ASSETS.md](ASSETS.md).

Do **not** use `_tmp_pixel_platformer/` — that folder is gitignored local reference only.

---

## Step 3 — Godot editor setup

1. **Open Godot 4.7-stable**
2. **Import** → select the cloned folder (or open `project.godot` directly)
3. Confirm the project loads without errors
4. **Project → Project Settings → Plugins**
5. Ensure **Godot MCP** is **enabled** (should already be on via `project.godot`)
6. Check the bottom panel tab **MCP** — it should show **listening** on `127.0.0.1:6550`

### If the Godot MCP addon is missing

The addon is committed under `addons/godot_mcp/`. If it's missing after clone, reinstall:

```powershell
npm run mcp:install-addon
```

Then enable the plugin in Godot (step 5 above) and restart the editor.

### First run

Press **F5** — Kenney tiles and character sprites load from `assets/placeholders/kenney/` (included in Git — no extra download). Godot may reimport PNGs on first open; wait for it to finish.

| Action | Keys |
|--------|------|
| Move | A/D or Arrow keys |
| Jump | Space / W / Up (double jump in air) |

---

## Step 4 — Cursor IDE setup

1. **File → Open Folder** → select the cloned `gramps-dont-dancewiththe-devil` folder (project root)
2. Cursor reads project config automatically:
   - `.cursorrules` — Godot 4 coding standards
   - `.cursor/mcp.json` — Godot MCP server (portable, no hardcoded paths)
3. **Reload Cursor:** `Ctrl+Shift+P` → **Developer: Reload Window**
4. Open **Settings → MCP** — confirm **godot-mcp** appears and status is **green**
5. You should see **21 tools** enabled

### MCP config (already in repo)

`.cursor/mcp.json` launches via `scripts/mcp/start-godot-mcp.cmd` (Windows). No per-machine path edits needed.

### If godot-mcp shows red / errored

| Check | Fix |
|-------|-----|
| `npm install` not run | Run `npm install` in project root |
| Godot not open | Open Godot with this project |
| MCP plugin disabled | Enable in Project Settings → Plugins |
| Port 6550 not listening | Restart Godot; check MCP bottom panel |
| Stale MCP process | Disable/enable godot-mcp in Cursor Settings → MCP |

**Important:** Keep **Godot open** while using Cursor agents — MCP talks to the editor over WebSocket.

### Do NOT add godot-mcp to global `~/.cursor/mcp.json`

Use the **project-level** `.cursor/mcp.json` only. Duplicate entries in the global config can cause connection conflicts (Godot accepts one MCP client at a time).

---

## Step 5 — Verify everything works

### Human check

- [ ] Godot F5 runs the level
- [ ] Cursor MCP shows godot-mcp green, 21 tools
- [ ] `git pull` works

### Cursor agent check (ask your agent)

Paste this into Cursor chat:

```
Verify my setup per docs/SETUP.md: run npm install if needed, call godot_project get_info and addon_status, confirm Godot MCP is connected.
```

Expected: agent returns project name `GrampsDontDancewiththeDevil`, Godot 4.7, addon/server versions match.

---

## Step 6 — Daily collaboration workflow (Git + Pull Requests)

> **Default branch:** `master` (not `main`). **Partner (JK) works on:** `jky`.

Full beginner guide: **[GITHUB_WORKFLOW.md](GITHUB_WORKFLOW.md)**

**JK — start of every session:**

```powershell
git checkout jky
git pull origin jky
git fetch origin
git merge origin/master

# ... edit, test F5 ...

git add .
git commit -m "Describe what changed"
git push origin jky
```

Then open a **Pull Request** on GitHub: **base `master`**, **compare `jky`**. Ryan reviews and merges.

**Ryan — works on `master` directly.** See [FOR_LEAD_DEVELOPER.md](FOR_LEAD_DEVELOPER.md).

---

## Cursor agent bootstrap (automated)

**For AI agents:** when a user clones this repo or says "set up the project", execute in order:

1. `node --version` — must be 20+
2. `npm install` — project root
3. Confirm files exist: `.cursor/mcp.json`, `addons/godot_mcp/plugin.cfg`, `scripts/mcp/start-godot-mcp.cmd`
4. Confirm Kenney placeholder art: `assets/placeholders/kenney/tiles_packed.png` and `characters_packed.png` (see [ASSETS.md](ASSETS.md))
5. Tell user to open `project.godot` in Godot 4.7-stable and confirm MCP plugin enabled
6. Tell user to open this folder in Cursor and **reload window**
7. Call MCP `godot_project` → `get_info` and `addon_status` when Godot is open
8. Read `docs/AGENTS.md`, `docs/GAME_DESIGN.md`, `docs/ARCHITECTURE.md`, `docs/ASSETS.md` before implementing features

**Do not** clone or add `_tmp_pixel_platformer/` — it is gitignored local reference only. Game art is in `assets/placeholders/kenney/`.

**Do not** hardcode machine-specific paths in `.cursor/mcp.json`.

**Do not** commit `.godot/`, `node_modules/`, or `builds/*.exe`.

---

## Partner onboarding prompt (copy-paste into Cursor)

Give this to your partner the first time they open the project in Cursor:

```
I just cloned GramsBewareoftheDevil. Follow docs/SETUP.md step by step:
1) Run npm install
2) git checkout jky && git pull origin jky
3) Verify assets/placeholders/kenney/ has tiles_packed.png and characters_packed.png (docs/ASSETS.md)
4) Walk me through Godot 4.7 setup and enabling the MCP plugin
5) Reload Cursor and verify godot-mcp is green with 21 tools
6) Run the game via MCP or tell me to press F5
Then read docs/AGENTS.md, docs/GAME_DESIGN.md, and docs/GITHUB_WORKFLOW.md.
I work ONLY on the jky branch — never master. Do NOT clone or use _tmp_pixel_platformer.
```

---

## Troubleshooting

### "Cannot reach Godot at ws://127.0.0.1:6550"

Godot editor is not running, or MCP plugin is not listening. Open Godot → check MCP panel.

### "node_modules missing" when starting MCP

Run `npm install` from project root.

### Godot asks to upgrade project version

You opened with the wrong Godot version. Install **4.7-stable** and reopen.

### MCP works but tools fail after editing project.godot

Restart Godot editor (or MCP `godot_editor_edit` restart) so input map / autoloads reload.

### Sprites or tiles missing (pink squares)

Placeholder art is in `assets/placeholders/kenney/`. See [ASSETS.md](ASSETS.md). Do **not** clone `_tmp_pixel_platformer` — that folder is gitignored.

### Addon/server version mismatch

```powershell
npm run mcp:install-addon
```

Restart Godot.

---

## Optional: Windows export (for non-technical playtesters)

If someone without Godot needs to play:

1. Godot → **Editor → Manage Export Templates** (4.7)
2. **Project → Export → Windows Desktop** → enable **Embed PCK**
3. Export to `builds/Gramps_latest.exe`

See [COLLABORATION.md](COLLABORATION.md) for naming and feedback templates.

---

## Quick reference

| What | Where |
|------|-------|
| Main scene | `scenes/levels/level_01.tscn` |
| Player movement | `scripts/player/player.gd` |
| MCP wrapper | `scripts/mcp/start-godot-mcp.cmd` |
| Agent rules | `docs/AGENTS.md` |
| Architecture | `docs/ARCHITECTURE.md` |
| Game vision / scope | `docs/GAME_DESIGN.md` |
