# For Ryan (Lead Developer)

**Share [GITHUB_WORKFLOW.md](GITHUB_WORKFLOW.md) with JK** — or walk him through it once. It explains the full `jky` → `master` workflow.

---

## One-page summary for JK

> "We share one GitHub repo. Ryan works on `master`. You work **only** on the `jky` branch. You never push to `master`. You test with **F5**, push to `jky`, then open a **Pull Request** (`jky` → `master`). I review, playtest, and merge. Then you sync `jky` with `master` and keep going. **Never delete `jky`.**"

**Repo:** https://github.com/ImightbeRafa/GramsBewareoftheDevil  
**Default branch:** `master` (not `main`)  
**Partner branch:** `jky`  
**Setup:** [SETUP.md](SETUP.md)  
**Git workflow:** [GITHUB_WORKFLOW.md](GITHUB_WORKFLOW.md)

---

## Before JK clones (your checklist)

### ✅ Already in the repo (committed)

| Item | Status |
|------|--------|
| Godot project (`project.godot`, scenes, scripts) | ✅ |
| Godot MCP addon (`addons/godot_mcp/`) | ✅ |
| Portable MCP config (`.cursor/mcp.json` + `scripts/mcp/`) | ✅ |
| Node deps (`package.json`, `package-lock.json`) | ✅ |
| Docs (SETUP, AGENTS, GITHUB_WORKFLOW, etc.) | ✅ |
| `.cursorrules` for AI coding standards | ✅ |
| `.gitignore` (excludes `.godot`, `node_modules`, builds) | ✅ |
| PR template (`.github/pull_request_template.md`) | ✅ |

### ⚠️ You must do (one-time)

| # | Task | Steps |
|---|------|-------|
| 1 | **Invite JK on GitHub** | Repo → **Settings** → **Collaborators and teams** → **Add people** → enter his GitHub username → role **Write** → he must **Accept** the email invite |
| 2 | **Create and push `jky` branch** | See commands below |
| 3 | **Branch protection on `master`** | Settings → Branches → require PR before merge (optional: block force push) |
| 4 | **Push your latest local work** | Commit & push `master` so JK clones the real current state |
| 5 | **Confirm JK has Godot 4.7-stable** | Same version as you |

**Create `jky` (run once):**

```powershell
git checkout master
git pull origin master
git checkout -b jky
git push -u origin jky
```

### After JK clones

He runs: `git clone` → `git checkout jky` → `npm install` → open Godot → open Cursor → follow [SETUP.md](SETUP.md).

Send him the **onboarding prompt** from [SETUP.md](SETUP.md) or [GITHUB_WORKFLOW.md](GITHUB_WORKFLOW.md).

---

## Your review checklist (when JK opens a PR)

1. **Read the PR** on GitHub — what changed, how to test
2. **Checkout `jky` locally:**

   ```powershell
   git fetch origin
   git checkout jky
   git pull origin jky
   ```

3. **Godot F5** — play the level, check movement, no errors in Output panel
4. **Scope** — does it match [GAME_DESIGN.md](GAME_DESIGN.md)? No surprise combat/story if you didn't agree
5. **Merge or request changes** on GitHub (prefer **Create a merge commit**)
6. **`git checkout master && git pull origin master`** after merge
7. Tell JK: _"Merged — sync jky with master (`git merge origin/master`) and keep going"_

---

## Recommended GitHub settings

**Branch protection (`master`):**

- Require pull request before merging: **ON** (blocks JK from pushing to `master`)
- **Allow specified actors to bypass** → add **yourself (Ryan)** if you want to keep pushing directly to `master`
- Required approvals: **0** (you're the only merger)
- Allow force pushes: **OFF**
- Allow deletions: **OFF**

**Why:** Branch protection is what actually prevents JK from pushing to `master`. Write access alone does not. Every JK change still goes through PR review before it lands on `master`.

**Collaborator role for JK:** **Write** — can push `jky`, cannot change repo settings.

---

## How JK's Cursor agent should behave

His agent should read [AGENTS.md](AGENTS.md). Key rules:

| Agent rule | Reason |
|------------|--------|
| **Work on `jky` only** | Never create `design/*` or other branch names |
| **Never push to `master`** | Only Ryan touches `master` |
| **Never merge PRs** | Ryan merges |
| **Never commit unless JK says "commit"** | JK controls checkpoints |
| **Sync `master` into `jky` before work** | Fresh start every session |
| **Test with F5 or Godot MCP before commit/PR** | No broken PRs |
| **Read GAME_DESIGN.md before new features** | Scope control |

**Prompt JK can pin in Cursor:**

```
This is GramsBewareoftheDevil. Read docs/AGENTS.md and docs/GITHUB_WORKFLOW.md.
Work ONLY on the jky branch — never master.
Before starting: git checkout jky, git pull origin jky, git merge origin/master.
Test in Godot (F5 or MCP) before I commit.
Never push to master or merge PRs — I open PRs for Ryan to review.
Never commit unless I explicitly say "commit".
```

---

## Fast-update workflow

| JK | Ryan |
|----|------|
| Small change → push `jky` → one PR | Review same day if possible |
| Don't stack unrelated features in one PR | Ask him to split big PRs |
| Message when PR is ready | `git fetch` + checkout `jky` + F5 |
| After merge: sync `jky` with `master` | Push your own work to `master` |

**Communication beats Git magic** — a quick ping _"PR up: jky → master"_ saves confusion.

---

## Docs map (what to point JK to)

| He needs… | Send him… |
|-----------|-----------|
| First-time install | [SETUP.md](SETUP.md) |
| Daily Git / PRs (`jky` workflow) | [GITHUB_WORKFLOW.md](GITHUB_WORKFLOW.md) |
| What the game is / isn't | [GAME_DESIGN.md](GAME_DESIGN.md) |
| Folder structure | [ARCHITECTURE.md](ARCHITECTURE.md) |
| Cursor AI rules | [AGENTS.md](AGENTS.md) |
| This overview | [FOR_LEAD_DEVELOPER.md](FOR_LEAD_DEVELOPER.md) (you) |

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| JK pushed to `master` | Turn on branch protection; revert commit if needed |
| PR won't merge (conflicts) | JK merges `master` into `jky`, resolves conflicts, pushes |
| "Works on his machine" | You checkout `jky` — never merge without F5 |
| MCP not working for him | [SETUP.md](SETUP.md) troubleshooting — Godot open, `npm install` |
| Godot version mismatch | Both install 4.7-stable |
| JK deleted `jky` locally | `git fetch origin && git checkout -b jky origin/jky` |
