# Collaboration Guide

Two-person team on one GitHub repo: **https://github.com/ImightbeRafa/GramsBewareoftheDevil**

> **First clone?** [SETUP.md](SETUP.md)  
> **Git branches & Pull Requests?** [GITHUB_WORKFLOW.md](GITHUB_WORKFLOW.md)  
> **Ryan's review guide?** [FOR_LEAD_DEVELOPER.md](FOR_LEAD_DEVELOPER.md)

> **Default branch:** `master` (not `main`)

## Roles

| Role | Person | Branch | Git responsibility |
|------|--------|--------|-------------------|
| **Lead developer** | Ryan | `master` | Reviews PRs, merges `jky` → `master`, owns technical direction |
| **Creative director** | JK | `jky` | Commits to `jky` only, opens PRs — **does not merge to `master`** |

## Daily workflow (summary)

```
JK: pull jky → merge master into jky → work → test F5 → commit → push jky → open PR (jky → master)
Ryan: review PR → F5 playtest → merge → pull master
JK: merge master into jky → continue on jky
```

See [GITHUB_WORKFLOW.md](GITHUB_WORKFLOW.md) for full commands.

## Playtesting

| Method | When |
|--------|------|
| **F5 in Godot** | Every session after syncing branches |
| **Cursor + MCP** | When Godot is open and MCP is green |
| **Exported `.exe`** | Optional — for people without Godot |

## Rules

| Rule | Why |
|------|-----|
| JK: **`jky` branch + PR only** | Ryan approves before `master` changes |
| Sync `master` into `jky` before new work | Start from Ryan's latest code |
| Test before PR | No broken builds in review |
| One person per scene file at a time | Avoid `.tscn` conflicts |
| Godot **4.7-stable** on both PCs | Version match |
| Godot open for Cursor MCP | Agent needs editor bridge |
| **Never delete `jky`** | It is JK's permanent workspace |

## What to commit

| ✅ Commit | ❌ Don't commit |
|-----------|----------------|
| `.gd`, `.tscn`, `.md`, `project.godot` | `.godot/` |
| `addons/godot_mcp/`, `scripts/mcp/` | `node_modules/` |
| `.cursor/mcp.json`, `package-lock.json` | `builds/*.exe` |

## Feedback template

```
PR: jky → master
Feel: (jump too high, love the platforms, etc.)
Bug: (steps to reproduce)
Ideas: (optional)
```

## AI agents (both machines)

Each Cursor agent must read [AGENTS.md](AGENTS.md) and [GITHUB_WORKFLOW.md](GITHUB_WORKFLOW.md).

**JK's agent:** work on `jky` only, never push to `master`, never merge PRs, never commit without explicit user request, always sync with `master` before work, always test before PR.

**Ryan's agent:** may work on `master`; never force-push `jky`; merge PRs only when Ryan explicitly asks.

## Repo

```
https://github.com/ImightbeRafa/GramsBewareoftheDevil
Default branch: master
Partner branch: jky
```
