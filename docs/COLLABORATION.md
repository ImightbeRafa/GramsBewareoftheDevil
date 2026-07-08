# Collaboration Guide

Two-person team sharing **one Git repo** — both use Godot, Cursor, and Godot MCP once set up.

> **First time on a new machine?** Follow [SETUP.md](SETUP.md) end-to-end before collaborating.

## Roles

| Role | Typical tasks |
|------|----------------|
| **Technical lead** (Ryan) | Scripts, systems, tooling, merges, architecture |
| **Creative director** (partner) | Level feel, layout ideas, scene tweaks, design feedback, playtesting |

Both can push to Git and use Cursor agents — coordinate to avoid editing the same scene at once.

## Daily workflow (Git-first)

```powershell
# Every session — both people, first thing
git pull

# Work in Godot and/or Cursor...

# When ready to share
git add .
git commit -m "Describe what changed"
git push
```

Announce in chat when you push something worth playtesting:

> _"Pushed: double jump + taller platforms on level_01 — pull and F5"_

### Partner's first clone

```powershell
git clone <YOUR_REPO_URL>
cd gramps-dont-dancewiththe-devil
```

Then follow **[SETUP.md](SETUP.md)** (npm install, Godot, Cursor MCP). Paste the **Partner onboarding prompt** from SETUP.md into Cursor if you want the agent to walk you through it.

## Playtesting

### With Godot (primary — both of you)

1. `git pull`
2. Open `project.godot` in Godot **4.7-stable**
3. Press **F5**

### With Cursor agent

1. `git pull`
2. Open project folder in Cursor
3. Godot must be **open** with MCP plugin enabled
4. Ask agent to run/playtest via MCP tools

### Optional: Windows `.exe` export

For someone **without** Godot installed (friends, family, future playtesters):

1. **Project → Export → Windows Desktop** (Embed PCK on)
2. Export to `builds/Gramps_latest.exe`
3. Share the file (Discord, drive, etc.)

Not required for day-to-day work between the two of you — Git is enough.

## Rules to avoid pain

| Rule | Why |
|------|-----|
| Run `git pull` before starting | Don't work on stale files |
| Never commit `.godot/`, `node_modules/`, `builds/*.exe` | Machine-specific / large |
| One person edits a given `.tscn` at a time | Scene merge conflicts are painful |
| Same Godot **4.7-stable** on both PCs | Version mismatch breaks the project |
| Keep Godot open when using Cursor MCP | Agent needs the editor bridge |
| Don't duplicate godot-mcp in global Cursor MCP config | Causes connection conflicts |

## What to commit

| Commit | Don't commit |
|--------|----------------|
| `.gd`, `.tscn`, `.md`, `project.godot` | `.godot/` |
| `addons/godot_mcp/` | `node_modules/` |
| `.cursor/mcp.json`, `.cursorrules` | `builds/*.exe` |
| `package.json`, `package-lock.json` | Secrets / API keys |
| `scripts/mcp/` | |

## Branching (simple)

- `main` — always playable
- `feature/short-description` — optional for bigger experiments
- Merge or push to `main` when ready for partner to pull

No complex GitFlow needed.

## Feedback template

Copy-paste when reporting after playtesting:

```
Commit / date: (e.g. abc1234 or "today's pull")
Feel: (too floaty / jump too high / love the double jump / etc.)
Bug: (what happened, steps to reproduce)
Fun: (what was enjoyable, what felt boring)
Ideas: (level layout, mechanics — no need to implement now)
```

## Repo URL

Paste your remote here once created:

```
Git remote: <YOUR_REPO_URL>
```

## AI agents on both machines

Each person's Cursor agent should read:

1. [SETUP.md](SETUP.md) — environment bootstrap
2. [AGENTS.md](AGENTS.md) — how to work on this project
3. [GAME_DESIGN.md](GAME_DESIGN.md) — scope boundaries

Same rules, same MCP setup, same repo — full collaboration.
