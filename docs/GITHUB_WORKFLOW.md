# GitHub Workflow (Beginners)

How two people collaborate on **GramsBewareoftheDevil** without overwriting each other's work.

**Repository:** https://github.com/ImightbeRafa/GramsBewareoftheDevil

**Default branch:** `master` (the “official” version — only merge here after review)

---

## The golden rules

| Rule | Why |
|------|-----|
| **`master` is protected** | Only the lead developer merges into `master` after review |
| **Never push directly to `master`** (brother) | Prevents breaking the game for everyone |
| **Always use branches** | Your work stays separate until approved |
| **Open a Pull Request (PR)** | Ryan reviews your changes before they go live |
| **`git pull` before starting** | You start from the latest code |
| **Test before you PR** | Press F5 in Godot — no script errors |

---

## Roles

| Person | GitHub role | Git permissions |
|--------|-------------|-----------------|
| **Ryan (lead / technical)** | Owner, reviewer, merger | Can merge PRs into `master` |
| **Brother (creative director)** | Collaborator | Push branches, open PRs — **do not merge** |

---

## Brother's workflow (every change)

### 1. Start fresh

```powershell
cd GramsBewareoftheDevil
git checkout master
git pull origin master
```

### 2. Create a branch (never work on `master`)

```powershell
git checkout -b design/short-description
```

**Branch naming examples:**

| Prefix | Use for |
|--------|---------|
| `design/` | Level layout, feel tweaks, scene edits |
| `feature/` | New mechanics, enemies, systems |
| `fix/` | Bug fixes |
| `docs/` | Documentation only |

Examples: `design/level-01-platforms`, `feature/patrol-enemy`, `fix/jump-height`

### 3. Make changes

- Edit in Godot and/or Cursor
- Press **F5** — game must run without errors
- Commit when ready (see step 4)

### 4. Commit and push your branch

```powershell
git add .
git status
git commit -m "Add taller platforms and adjust jump feel"
git push -u origin design/short-description
```

First push on a new branch uses `-u` so future pushes are just `git push`.

### 5. Open a Pull Request on GitHub

1. Go to https://github.com/ImightbeRafa/GramsBewareoftheDevil
2. GitHub will show **“Compare & pull request”** after your push — click it
3. Fill in the PR template (what changed, how to test)
4. Click **Create pull request**
5. Message Ryan: _“PR ready for review: design/level-01-platforms”_

**Do not click Merge.** Ryan does that after review.

### 6. After Ryan merges

```powershell
git checkout master
git pull origin master
git branch -d design/short-description
```

---

## Ryan's workflow (review & merge)

### When brother opens a PR

1. Open the PR on GitHub — read description and **Files changed** tab
2. **Test locally** (important):

```powershell
git fetch origin
git checkout design/short-description
# Open Godot, press F5, playtest
```

3. **Decision:**
   - **Approve + Merge** — if it works and fits scope
   - **Request changes** — leave a comment on the PR explaining what to fix
4. On GitHub: **Merge pull request** → **Confirm merge**
5. Update your local `master`:

```powershell
git checkout master
git pull origin master
```

### When Ryan makes changes

Ryan can either:

- **Small fixes:** commit directly to `master` (lead privilege), or
- **Bigger features:** use the same branch + PR habit for safety

After pushing to `master`, message brother: _“Pulled to latest master — new stuff on player movement”_

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

A template file lives at `.github/pull_request_template.md` — GitHub fills it automatically.

---

## GitHub setup (Ryan — one-time, recommended)

Protect `master` so brother cannot accidentally merge or push to it:

1. GitHub repo → **Settings** → **Branches**
2. **Add branch protection rule**
3. Branch name: `master`
4. Enable:
   - ☑ **Require a pull request before merging**
   - ☑ **Require approvals** (1 approval — Ryan approves his own if needed, or skip if only Ryan merges manually)
5. Optional: ☑ **Do not allow bypassing the above settings**

Also invite brother:

1. **Settings** → **Collaborators**
2. **Add people** → brother's GitHub username → role **Write** (can push branches, not admin)

---

## Fixing merge conflicts (when Git says “conflict”)

Happens when both edited the same file. **Don't panic.**

1. `git pull origin master` on your branch (or GitHub will show conflict in PR)
2. Open conflicted files — look for `<<<<<<<` markers
3. Fix manually or ask your Cursor agent for help
4. `git add .` → `git commit` → `git push`

**Prevention:** communicate who's editing `level_01.tscn` or `player.gd` at the same time.

---

## Quick command cheat sheet

| Task | Command |
|------|---------|
| Get latest | `git pull origin master` |
| New branch | `git checkout -b design/my-change` |
| See status | `git status` |
| Save work | `git add .` then `git commit -m "message"` |
| Upload branch | `git push` |
| Switch branch | `git checkout branch-name` |
| Back to official | `git checkout master` |

---

## What never goes in Git

- `.godot/` (editor cache)
- `node_modules/` (run `npm install` after clone)
- `builds/*.exe` (exported games)
- Passwords, API keys

These are already in `.gitignore`.

---

## Related docs

- [SETUP.md](SETUP.md) — first-time machine setup
- [COLLABORATION.md](COLLABORATION.md) — team roles and daily habits
- [AGENTS.md](AGENTS.md) — rules for Cursor AI on both machines
