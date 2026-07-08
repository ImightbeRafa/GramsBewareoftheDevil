# Game Design

> **Scope freeze (Session 1):** One playable 2D platformer level with move/jump/obstacles. No combat, items, story, or special levels until movement feel is approved.

## Vision

**Gramps Don't Dance with the Devil** is a 2D level-based platformer with story progression across handcrafted levels — inspired by the pacing and variety of classic **Sonic**, **Mario**, and **Mega Man** games.

Players will eventually:

- Progress through levels with narrative beats
- Collect items and unlock abilities
- Use movement and attack mechanics
- Encounter special/bonus levels

## Session 1 prototype goals

| Goal | Status |
|------|--------|
| Responsive move + jump on `CharacterBody2D` | Done — awaiting feel sign-off |
| Coyote time + jump buffer + short-hop on release | Done — awaiting feel sign-off |
| Single test level with platforms and gaps | Done |
| Hazard (respawn at spawn point) | Done |
| Goal zone (clear feedback) | Done |
| Reusable `player.tscn` scene | Done |
| Docs for humans and AI agents | Done |

## Explicit non-goals (until prototype feel is signed off)

- Combat, weapons, enemies with AI
- Inventory, pickups, power-ups
- Story scenes, dialogue, cutscenes
- Level select / world map
- Save system
- Audio pipeline (beyond placeholder)
- TileMap-based level authoring (deferred to Session 2+)
- Attack mechanics
- Special levels

## Future pillars (later)

### Levels

- Handcrafted stages with increasing difficulty
- Optional secret routes and collectibles
- Boss or gate encounters at level end

### Movement

- Current base: run, jump, double jump (resets on landing), coyote, buffer
- Later candidates: dash, wall jump, slope polish, run charge (Sonic-style) — only after base feel is fun

### Story & progression

- Lore and character motivation (Gramps theme TBD)
- Level-to-level narrative unlocks

### Items & attacks

- TBD once core platforming loop is fun in isolation

## Feel target

**Snappy Mario-ish** — not Sonic speed yet. Movement should feel forgiving (coyote/buffer) but responsive. All tunables are `@export` on the player script for quick iteration in the inspector.

## Success criteria for Session 1

1. Two beginners can run the level and give feedback within minutes
2. Partner can play without opening Godot (via exported `.exe`)
3. Movement is fun enough to want to add more platforms/obstacles
4. Project structure is clear enough for AI agents to extend without rewrites
