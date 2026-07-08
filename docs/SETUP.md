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
git clone <YOUR_REPO_URL>
cd gramps-dont-dancewiththe-devil
```

Replace `<YOUR_REPO_URL>` with your GitHub/GitLab private repo URL (ask the main developer if you don't have it).

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

Press **F5** — you should see `level_01` with move/jump/double-jump controls.

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

## Step 6 — Daily collaboration workflow (Git)

Both of you work from the **same repo**. No separate build drops required — `git pull` is the sync.

```powershell
# Start of every session (both people)
git pull

# After you make changes
git add .
git commit -m "Short description of what changed"
git push
```

### Roles

| Person | Typical work |
|--------|----------------|
| **Technical lead** | Scripts, systems, project settings, MCP/tooling |
| **Creative director** | Level layout, feel feedback, scene tweaks, design docs |

Both can use **Godot + Cursor + MCP** once set up.

### Avoid merge pain

- `git pull` before starting work
- Coordinate who edits the same `.tscn` file (scene conflicts are annoying)
- Communicate in chat: _"I'm editing level_01"_ / _"pushed movement tweaks"_

---

## Cursor agent bootstrap (automated)

**For AI agents:** when a user clones this repo or says "set up the project", execute in order:

1. `node --version` — must be 20+
2. `npm install` — project root
3. Confirm files exist: `.cursor/mcp.json`, `addons/godot_mcp/plugin.cfg`, `scripts/mcp/start-godot-mcp.cmd`
4. Tell user to open `project.godot` in Godot 4.7-stable and confirm MCP plugin enabled
5. Tell user to reload Cursor window
6. Call MCP `godot_project` → `get_info` and `addon_status` when Godot is open
7. Read `docs/AGENTS.md`, `docs/GAME_DESIGN.md`, `docs/ARCHITECTURE.md` before implementing features

**Do not** hardcode machine-specific paths in `.cursor/mcp.json`.

**Do not** commit `.godot/`, `node_modules/`, or `builds/*.exe`.

---

## Partner onboarding prompt (copy-paste into Cursor)

Give this to your partner the first time they open the project in Cursor:

```
I just cloned gramps-dont-dancewiththe-devil. Follow docs/SETUP.md step by step:
1) Run npm install
2) Walk me through Godot 4.7 setup and enabling the MCP plugin
3) Reload Cursor and verify godot-mcp is green with 21 tools
4) Run the game via MCP or tell me to press F5
Then read docs/AGENTS.md and docs/GAME_DESIGN.md so you understand project scope.
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
