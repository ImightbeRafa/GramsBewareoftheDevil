# GitHub Workflow (Beginners)

How two people collaborate on **GramsBewareoftheDevil** without overwriting each other's work.

**Repository:** https://github.com/ImightbeRafa/GramsBewareoftheDevil

> **Important:** The default branch is **`master`**, not `main`. Every command in this doc uses `master`. If you see `main` in a tutorial elsewhere, substitute `master` for this repo.

---

## The golden rules

| Rule | Why |
|------|-----|
| **`master` is the official version** | Only Ryan merges into `master` after review |
| **JK never pushes to `master`** | Prevents breaking the game for everyone |
| **JK always works on the `jky` branch** | One long-lived branch — no new branch names each session |
| **Open a Pull Request (`jky` → `master`)** | Ryan reviews before changes go live |
| **Sync before you work** | Pull latest `jky`, then merge `master` into `jky` |
| **Test before you PR** | Press F5 in Godot — no script errors |

---

## Roles

| Person | GitHub role | Where they work | What they can do |
|--------|-------------|-----------------|------------------|
| **Ryan (lead / technical)** | Owner | `master` | Commit to `master`, review PRs, merge PRs |
| **JK (creative director / partner)** | Collaborator (Write) | `jky` only | Push to `jky`, open PRs — **never merge, never push `master`** |

---

## One-time setup (Ryan — before JK clones)

### 1. Add JK as a GitHub collaborator

1. Open https://github.com/ImightbeRafa/GramsBewareoftheDevil
2. Click **Settings** (top menu — you must be the repo owner)
3. In the left sidebar, click **Collaborators and teams** (under "Access")
4. Click **Add people**
5. Enter JK's **GitHub username** or the email on his GitHub account
6. Select role: **Write** (can push branches and open PRs — not Admin)
7. Click **Add [username] to this repository**
8. JK receives an email invite — he must **Accept** before he can push

**Write access means:** JK can clone, push branches, and open PRs. He cannot change repo settings or delete the repo.

> **Important:** Write access alone does **not** block pushes to `master`. JK could still push to `master` by mistake unless you enable **branch protection** on `master` (step 3 below). Protection is what actually enforces the rule — not the collaborator role.

### 2. Create the `jky` branch (Ryan does this once)

Ryan creates the partner branch from the latest `master` so JK can clone and check it out immediately:

```powershell
cd GramsBewareoftheDevil
git checkout master
git pull origin master
git checkout -b jky
git push -u origin jky
```

### 3. Protect `master` (strongly recommended)

This is what **actually stops** JK from pushing to `master`. Write access alone is not enough.

1. Repo → **Settings** → **Branches**
2. **Add branch protection rule**
3. Branch name pattern: `master`
4. Enable:
   - ☑ **Require a pull request before merging**
   - ☑ **Do not allow bypassing the above settings** (optional but safest for JK)
5. Leave **Allow force pushes** and **Allow deletions** **OFF**
6. Save

**Note for Ryan (repo owner):** As owner, you can usually still push directly to `master` even with "Require a pull request" enabled — owners often have admin bypass. If you find you **cannot** push to `master` anymore, either:
- Enable **Allow specified actors to bypass required pull requests** and add yourself, or
- Turn off "Require a pull request" and rely on JK following the docs (less safe)

Pick what fits your workflow. The critical part is JK cannot merge PRs and should not push to `master`.

---

## One-time setup (JK — after accepting the invite)

### 1. Clone the repo

```powershell
git clone https://github.com/ImightbeRafa/GramsBewareoftheDevil.git
cd GramsBewareoftheDevil
```

### 2. Install project dependencies

Follow [SETUP.md](SETUP.md) — `npm install`, Godot 4.7-stable, Cursor MCP, etc.

### 3. Switch to the `jky` branch

```powershell
git fetch origin
git checkout jky
git pull origin jky
```

You should see `* jky` when you run `git branch`. **Stay on `jky` for all future work.**

### 4. Pin the agent prompt in Cursor

Paste this into Cursor the first time (and keep it as a pinned rule if you use one):

```
This is GramsBewareoftheDevil. Read docs/AGENTS.md and docs/GITHUB_WORKFLOW.md before any Git or code work.
I work ONLY on the jky branch — never master.
Before starting: git checkout jky, git pull origin jky, git merge origin/master.
Test in Godot (F5 or MCP) before I commit.
Never push to master or merge PRs — I open PRs for Ryan to review.
Never commit unless I explicitly say "commit".
```

---

## JK's daily workflow (every session)

### Step 1 — Start on `jky` and sync with Ryan's latest `master`

```powershell
cd GramsBewareoftheDevil
git checkout jky
git pull origin jky
git fetch origin
git merge origin/master
```

**Why merge `master` into `jky`?** Ryan may have merged your last PR or made his own fixes on `master`. This step brings those changes into your branch so you don't work on stale code.

If Git reports **merge conflicts**, see [Fixing merge conflicts](#fixing-merge-conflicts) below.

### Step 2 — Make your changes

- Edit in Godot and/or Cursor
- Press **F5** — game must run without errors in the Output panel
- Coordinate with Ryan if you are both editing the same scene (e.g. `level_01.tscn`)

### Step 3 — Commit and push to `jky`

Only commit when **you** decide (your Cursor agent must not commit unless you say so):

```powershell
git add .
git status
git commit -m "Add taller platforms and adjust jump feel"
git push origin jky
```

### Step 4 — Open a Pull Request on GitHub

1. Go to https://github.com/ImightbeRafa/GramsBewareoftheDevil
2. GitHub may show **"Compare & pull request"** after your push — click it  
   **Or:** **Pull requests** tab → **New pull request**
3. Set:
   - **base:** `master` ← Ryan's official branch
   - **compare:** `jky` ← your branch
4. Fill in the PR template (what changed, how to test)
5. Click **Create pull request**
6. Message Ryan: _"PR ready: jky → master — level platform tweaks"_

**Do not click Merge.** Ryan does that after review.

**One PR per logical batch:** When Ryan merges your PR, open a **new** PR for the next batch of changes. Do not leave one PR open forever with unrelated work piled up.

### Step 5 — After Ryan merges your PR

**Do not delete the `jky` branch.** It is your permanent workspace.

```powershell
git checkout jky
git pull origin jky
git fetch origin
git merge origin/master
git push origin jky
```

Now `jky` matches what is on `master` plus any new work you start next.

---

## Ryan's workflow (review & merge)

### When JK opens a PR (`jky` → `master`)

1. Open the PR on GitHub — read description and **Files changed** tab
2. **Test locally** (important):

```powershell
git fetch origin
git checkout jky
# Open Godot, press F5, playtest what JK changed
```

3. **Decision:**
   - **Approve + Merge** — if it works and fits scope ([GAME_DESIGN.md](GAME_DESIGN.md))
   - **Request changes** — leave a comment on the PR explaining what to fix
4. On GitHub: **Merge pull request**
   - Prefer **Create a merge commit** (keeps `jky` history clean for the next sync)
   - Avoid **Squash and merge** unless you know JK will sync carefully afterward
5. Update your local `master`:

```powershell
git checkout master
git pull origin master
```

6. Tell JK: _"Merged — sync `jky` with `master` and keep going"_

### When Ryan makes changes on `master`

Ryan works directly on `master` (lead privilege):

```powershell
git checkout master
git pull origin master
# ... edit, test F5 ...
git add .
git commit -m "Fix dash cooldown"
git push origin master
```

Message JK: _"Pushed to master — run merge origin/master on your jky branch before your next session"_

---

## Visual: how the branches flow

```
Ryan's machine                         GitHub                         JK's machine
─────────────                         ──────                         ────────────

master ──commit──► master ─────────────────────────────► (JK merges master into jky)

jky ◄── PR review ◄── jky ◄── push ── jky ◄── commit ── jky
         merge
master ◄────────── master (updated after merge)
```

**Summary:** JK pushes to `jky`. PR goes `jky` → `master`. Ryan merges. Both sync. Repeat.

---

## Pull Request template (what to write)

```markdown
## What changed
- (bullet list)

## How to test
1. Open Godot, press F5
2. (specific steps — e.g. "jump across new platforms on the right")

## Scope check
- [ ] No combat/story/items unless we agreed on it
- [ ] Game runs without script errors
```

A template file lives at `.github/pull_request_template.md` — GitHub fills it automatically when you open a PR.

---

## Fixing merge conflicts

Happens when both edited the same lines in the same file. **Don't panic.**

On JK's machine, on the `jky` branch:

```powershell
git checkout jky
git fetch origin
git merge origin/master
```

Git will list conflicted files. Open them and look for markers:

```
<<<<<<< HEAD
(your version)
=======
(Ryan's version from master)
>>>>>>> origin/master
```

1. Edit the file to keep the correct code (or combine both)
2. Remove the `<<<<<<<`, `=======`, `>>>>>>>` lines
3. Save the file
4. Finish the merge:

```powershell
git add .
git commit -m "Merge master into jky — resolve conflicts"
git push origin jky
```

**Prevention:** Tell each other when you are editing the same scene (`level_01.tscn`, `player.gd`, etc.).

---

## Quick command cheat sheet

| Task | Command |
|------|---------|
| Switch to your branch | `git checkout jky` |
| Get latest `jky` from GitHub | `git pull origin jky` |
| Get Ryan's latest official code | `git fetch origin` then `git merge origin/master` |
| See status | `git status` |
| Save work | `git add .` then `git commit -m "message"` |
| Upload your branch | `git push origin jky` |
| Ryan: switch to official | `git checkout master` |
| Ryan: get latest master | `git pull origin master` |

---

## What never goes in Git

- `.godot/` (editor cache)
- `node_modules/` (run `npm install` after clone)
- `builds/*.exe` (exported games)
- Passwords, API keys

These are already in `.gitignore`.

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| "Permission denied" when pushing | Accept GitHub invite; confirm you are pushing to `jky`, not `master` |
| Accidentally committed on `master` (before push) | Do **not** push. Run `git checkout jky`, then `git cherry-pick <commit-hash>` to copy the commit onto `jky`. Or ask Ryan for help. |
| Accidentally pushed to `master` | Tell Ryan immediately — he may need to revert on GitHub |
| PR shows conflicts | Merge `origin/master` into `jky`, resolve, push |
| "Branch jky does not exist" | Ryan has not created/pushed `jky` yet — ask him to run the one-time setup |
| Pushed broken code | Tell Ryan immediately; he can request changes or revert |

---

## Related docs

- [SETUP.md](SETUP.md) — first-time machine setup
- [COLLABORATION.md](COLLABORATION.md) — team roles and daily habits
- [AGENTS.md](AGENTS.md) — rules for Cursor AI on both machines
- [FOR_LEAD_DEVELOPER.md](FOR_LEAD_DEVELOPER.md) — Ryan's quick reference
