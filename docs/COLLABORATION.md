# Collaboration Guide

Two-person team on one GitHub repo: **https://github.com/ImightbeRafa/GramsBewareoftheDevil**

> **First clone?** [SETUP.md](SETUP.md)  
> **Git branches & Pull Requests?** [GITHUB_WORKFLOW.md](GITHUB_WORKFLOW.md)  
> **Ryan's review guide?** [FOR_LEAD_DEVELOPER.md](FOR_LEAD_DEVELOPER.md)

## Roles

| Role | Person | Git responsibility |
|------|--------|-------------------|
| **Lead developer** | Ryan | Reviews PRs, merges into `master`, owns technical direction |
| **Creative director** | Brother | Branches, PRs for review — **does not merge to `master`** |

## Daily workflow (summary)

```
pull master → new branch → work → test F5 → commit → push branch → open PR → Ryan reviews → merge → pull master
```

See [GITHUB_WORKFLOW.md](GITHUB_WORKFLOW.md) for full commands.

## Playtesting

| Method | When |
|--------|------|
| **F5 in Godot** | Every session after `git pull` |
| **Cursor + MCP** | When Godot is open and MCP is green |
| **Exported `.exe`** | Optional — for people without Godot |

## Rules

| Rule | Why |
|------|-----|
| Brother: **branch + PR only** | Ryan approves before `master` changes |
| `git pull` on `master` before new branch | Start from latest |
| Test before PR | No broken builds in review |
| One person per scene file at a time | Avoid `.tscn` conflicts |
| Godot **4.7-stable** on both PCs | Version match |
| Godot open for Cursor MCP | Agent needs editor bridge |

## What to commit

| ✅ Commit | ❌ Don't commit |
|-----------|----------------|
| `.gd`, `.tscn`, `.md`, `project.godot` | `.godot/` |
| `addons/godot_mcp/`, `scripts/mcp/` | `node_modules/` |
| `.cursor/mcp.json`, `package-lock.json` | `builds/*.exe` |

## Feedback template

```
PR / branch: design/level-tweaks
Feel: (jump too high, love the platforms, etc.)
Bug: (steps to reproduce)
Ideas: (optional)
```

## AI agents (both machines)

Each Cursor agent must read [AGENTS.md](AGENTS.md) and [GITHUB_WORKFLOW.md](GITHUB_WORKFLOW.md).

**Brother's agent:** never push to `master`, never merge PRs, never commit without explicit user request, always test before PR.

## Repo

```
https://github.com/ImightbeRafa/GramsBewareoftheDevil
Default branch: master
```
