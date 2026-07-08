# For Ryan (Lead Developer)

**Share this doc with your brother** — or walk him through it once. It explains how you work together on GitHub.

---

## One-page summary for your brother

> “We share one GitHub repo. You never push to `master` directly. You make a **branch**, do your work, test with **F5**, then open a **Pull Request**. I review it, playtest it, and merge if it's good. Then you `git pull` and start again.”

**Repo:** https://github.com/ImightbeRafa/GramsBewareoftheDevil  
**Setup:** [SETUP.md](SETUP.md)  
**Git workflow:** [GITHUB_WORKFLOW.md](GITHUB_WORKFLOW.md)

---

## Is everything ready for him to clone?

### ✅ Already in the repo (committed)

| Item | Status |
|------|--------|
| Godot project (`project.godot`, scenes, scripts) | ✅ |
| Godot MCP addon (`addons/godot_mcp/`) | ✅ |
| Portable MCP config (`.cursor/mcp.json` + `scripts/mcp/`) | ✅ |
| Node deps (`package.json`, `package-lock.json`) | ✅ |
| Docs (SETUP, AGENTS, ARCHITECTURE, GAME_DESIGN, GITHUB_WORKFLOW) | ✅ |
| `.cursorrules` for AI coding standards | ✅ |
| `.gitignore` (excludes `.godot`, `node_modules`, builds) | ✅ |
| PR template (`.github/pull_request_template.md`) | ✅ |

### ⚠️ `_tmp_pixel_platformer/` — do not commit

That folder is a **local Kenney tutorial clone** with its own `.git`. It is now **gitignored**. Real game art is in `assets/placeholders/kenney/` — that **is** committed and partners get it on clone. See [ASSETS.md](ASSETS.md).

### ⚠️ You should do before he clones (one-time)

| Task | Where |
|------|--------|
| **Invite brother on GitHub** | Repo → Settings → Collaborators → Add |
| **Branch protection on `master`** | Settings → Branches → require PR before merge |
| **Push your latest local work** | You have uncommitted changes — commit & push when ready |
| **Confirm he has Godot 4.7-stable** | Same version as you |

### After he clones

He runs: `git clone` → `npm install` → open Godot → open Cursor → follow [SETUP.md](SETUP.md).

Paste him the **onboarding prompt** from SETUP.md into Cursor.

---

## Your review checklist (when he opens a PR)

1. **Read the PR** on GitHub — what changed, how to test
2. **Checkout his branch locally:**
   ```powershell
   git fetch origin
   git checkout his-branch-name
   ```
3. **Godot F5** — play the level, check movement, no errors in Output panel
4. **Scope** — does it match [GAME_DESIGN.md](GAME_DESIGN.md)? No surprise combat/story if you didn't agree
5. **Merge or request changes** on GitHub
6. **`git checkout master && git pull`** after merge
7. Tell him: _“Merged — pull master and start a new branch”_

---

## Recommended GitHub settings (copy-paste for yourself)

**Branch protection (`master`):**

- Require pull request before merging: **ON**
- Required approvals: **0 or 1** (you're the only merger — 0 is fine if only you click Merge)
- Allow force pushes: **OFF**
- Allow deletions: **OFF**

**Why:** Brother can't accidentally become the source of truth on `master`; every change gets a review step.

---

## How his Cursor agent should behave

His agent should read [AGENTS.md](AGENTS.md) plus these **extra rules for the creative director**:

| Agent rule | Reason |
|------------|--------|
| **Never push to `master`** | Only branches |
| **Never merge PRs** | Ryan merges |
| **Never commit unless he says “commit”** | He controls checkpoints |
| **Always `git pull` on `master` before new branch** | Fresh start |
| **Test with F5 or Godot MCP before commit/PR** | No broken PRs |
| **Read GAME_DESIGN.md before new features** | Scope control |
| **One PR per logical change** | Easier review when updates are fast |

**Prompt he can pin in Cursor:**

```
This is the GramsBewareoftheDevil Godot project. Before any code change:
1. Read docs/AGENTS.md, docs/GITHUB_WORKFLOW.md, docs/GAME_DESIGN.md
2. Work only on a branch (design/* or feature/*), never master
3. Test in Godot (F5 or MCP) before asking me to commit
4. Never push to master or merge PRs — I open PRs for Ryan to review
5. Never commit unless I explicitly ask
```

---

## Fast-update workflow (when changes come very fast)

| Brother | Ryan |
|---------|------|
| Small change → one branch → one PR | Review same day if possible |
| Don't stack 10 features in one PR | Ask him to split big PRs |
| Message when PR is ready | `git fetch` + checkout branch + F5 |
| After merge: `git pull` on master | Push your own work to master or PR |

**Communication beats Git magic** — a Discord/chat ping _“PR up: design/level-tweaks”_ saves confusion.

---

## Your local status (as of last audit)

- Remote: `origin` → https://github.com/ImightbeRafa/GramsBewareoftheDevil.git
- Branch: `master`
- **Uncommitted local work exists** (enemies, level changes, etc.) — **push when you're ready** so brother clones the real current state

```powershell
git add .
git commit -m "Describe current prototype state"
git push origin master
```

---

## Docs map (what to point him to)

| He needs… | Send him… |
|-----------|-----------|
| First-time install | [SETUP.md](SETUP.md) |
| Daily Git / PRs | [GITHUB_WORKFLOW.md](GITHUB_WORKFLOW.md) |
| What the game is / isn't | [GAME_DESIGN.md](GAME_DESIGN.md) |
| Folder structure | [ARCHITECTURE.md](ARCHITECTURE.md) |
| Cursor AI rules | [AGENTS.md](AGENTS.md) |
| This overview | [FOR_LEAD_DEVELOPER.md](FOR_LEAD_DEVELOPER.md) (you) |

---

## Troubleshooting you might see

| Problem | Fix |
|---------|-----|
| Brother pushed to `master` | Turn on branch protection; revert commit if needed |
| PR won't merge (conflicts) | He merges `master` into his branch, resolves conflicts |
| “Works on his machine” | You checkout branch — never merge without F5 |
| MCP not working for him | [SETUP.md](SETUP.md) troubleshooting — Godot open, `npm install` |
| Godot version mismatch | Both install 4.7-stable |
