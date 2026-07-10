# Gramps Don't Dance with the Devil — Project Tracker

> Living task list + development roadmap. Add sprint items under **Now**; log playtest results in **Verify log**.

---

## Development roadmap

### Phase 1 — Mobility & basic map prototypes *(current)*

**Goal:** Build and tune movement so it feels real and empowering for this kind of platformer. Use small prototype maps (parkour test, shifting map) to stress-test every mechanic in every scenario we care about.

**In scope now:**
- Core movement: run, jump, coyote/buffer, double jump, fall gravity
- Abilities: dash, wall jump / wall slide / climb, glide, momentum, cane brace
- Cane kit: pogo (mouse aim), hook (pull + swing), smash (mouse aim)
- Prototype scenes: `parkour_test`, `shifting_map` (SceneRouter: P / O)

**Phase 1 complete when:**
- All current **and planned** movement mechanics work as intended in every scenario present in prototypes
- Hook, wall climb, jump, pogo range, dash, glide feel **magical** — not weird, not floaty, not inconsistent
- Partner playtest confirms feel is good enough to stop re-architecting movement and start scaling level design

**Known feel issues (active tuning):**
- Hook pull / swing feels off
- Wall climb / wall jump feels weird
- Jump arc / air control needs pass
- Pogo range and aim cone need tuning
- More feedback expected as we play — tune until Phase 1 gate is met

---

### Phase 2 — Map design & environment systems

**Goal:** Implement the full library of environment, hazards, traps, and reactive systems we want in the final game. Learn to author levels confidently with those tools.

**In scope:**
- Hazard types: spikes, poison/toxic, fire, lava, ice, darkness, etc.
- Traps, pressure plates, timed/triggered hazards
- Shifting / timed / triggered map layout changes
- Environment that reacts to player touch (crumble, movers, switches)
- Level authoring workflow (builders, skills, verify loops)
- One **full prototype map** that exercises everything above

**Phase 2 complete when:**
- Full prototype map exists with all environment features we plan to ship
- Team can design progression maps on demand using documented tools and patterns
- Shifting-map mechanic is proven fun at prototype quality (not final art)

---

### Phase 3 — Assets, theme & lore

**Goal:** Replace placeholders with original art/audio and define the game's identity.

**In scope:**
- Custom assets: character, enemies, tiles, backgrounds, VFX, SFX, music
- Biomes and visual themes
- Lore bible, side characters, story beats
- Game progression outline (world order, ability unlock curve, narrative arc)

**Phase 3 complete when:**
- Asset set covers all planned biomes and entities
- Lore and progression roadmap are written and agreed
- Theme is cohesive enough to build Phase 4 levels without placeholder confusion

---

### Phase 4 — Full game development

**Goal:** Build the real game level-by-level from the Phase 3 progression plan.

**In scope:**
- Levels, abilities, lore, puzzles, side characters as designed
- Difficulty and teaching curve aligned to progression doc

**Phase 4 complete when:**
- Entire planned progression is coded and playable start-to-finish (base game scope)

---

### Phase 5 — Testing & polish

**Goal:** Holistic playtest and feedback pass on the complete base game.

**Note:** Testing happens every phase; Phase 5 is the dedicated “everything peachy clean” pass once base game content exists.

**Phase 5 complete when:**
- Full playthroughs by team + external testers with no P0/P1 blockers
- Feel, readability, and progression validated for release candidate

---

## Current phase status

| Phase | Status | Notes |
|-------|--------|-------|
| 1 Mobility | **In progress** | Shifting map + cane rework shipped; hook/wall/jump tuning ongoing |
| 2 Map design | Started (early) | Shifting map 280×140, hazards partial — not Phase 2 complete |
| 3 Assets/lore | Not started | Kenney placeholders |
| 4 Full game | Not started | — |
| 5 Polish | Ongoing | Verify log every session |

---

## Now (Phase 1 focus)

- [ ] **Movement feel pass** — hook, wall climb, jump, pogo range (playtest notes below)
- [ ] Partner clone + test branch — ensure repo ready to commit/share
- [ ] Playtest shifting map 280×140 on layouts A–D
- [ ] Tune bay 0–2 poses after feel pass
- [ ] Godot MCP playtest when editor bridge connected

### Movement tuning backlog

- [x] Grok pass 2026-07-09: hook swing, wall climb on Up, pogo range, jump arc unified
- [ ] Partner playtest sign-off on parkour + shifting map
- [ ] Further hook/wall/jump tweaks from playtest notes

---

## Verify log

| Date | Scenario | Result | Notes |
|------|----------|--------|-------|
| 2026-07-09 | Code audit | FAIL | Atlas strip, ghost blocks, sparse map |
| 2026-07-09 | Map overhaul | PENDING | 280×140, 20 blocks, tiled visuals — in-editor playtest |
| 2026-07-09 | Grok Phase 1 review | FAIL→tuning | Movement fixes applied; partner playtest pending |

### Playtest checklist (shifting map)

- [ ] Shifting blocks = real tiles, standable tops
- [ ] Bay 0: A/C bridge; B/D stairs/pogo/freeze
- [ ] Bay 1: B high shelf; no toxic ghost box
- [ ] Bay 2: D crossbeam + fire orb
- [ ] Bays 3–5: hook/glide/smash routes
- [ ] HUD layout A–D
- [ ] Hook / wall / jump feel acceptable for Phase 1 gate

---

## Parking lot

- Pose foreshadow during WARNING
- Gamepad cane aim
- Unlock gating per bay (teaching mode)
- Ice, darkness, reactive env (Phase 2)
- Secret collectibles on layout-only ledges

---

## Done (2026-07-09 session)

- PlatformVisual Kenney tile grid (fixes random atlas strip)
- ShiftingBlock tiled visuals; toxic mist hidden
- Map 280×140, 6 bays, 20 shifting blocks, layout-gated routes
- Cane mouse-aim rework (pogo/hook/smash), compact HUD, hints
- Shift timing 8/1/1, nudge triggers, freeze 50% resume
- Level design skill: `.cursor/skills/level-design-loop/SKILL.md`
- Grok Phase 1 movement pass: hook swing, wall climb on Up, pogo 68px ray, unified jump (1 air jump)

---

## Repo notes for partner

- Godot **4.7**, main test scenes: `scenes/levels/shifting_map.tscn`, `scenes/levels/parkour_test.tscn`
- Run `npm install` if using Godot MCP addon
- In-game: **O** shifting map · **P** parkour · **Q** cane mode · **LMB** use · **E** freeze · **Shift** dash
