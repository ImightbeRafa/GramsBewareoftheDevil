class_name LadderFactory
extends RefCounted

## Canonical ladder spawner for all levels / map builders.
## Always use this (or the ladder.tscn scene) — do not hand-roll Area2D ladders.

const LADDER_SCENE: PackedScene = preload("res://scenes/platforms/ladder.tscn")
const MIN_HEIGHT_TILES: int = 2
const DEFAULT_HEIGHT_TILES: int = 8


## Spawns a standard climbable ladder.
## `base_position` = bottom-center of the ladder (sit this on the platform top / floor).
## `height_tiles` = height in Kenney tiles (18px each). Clamped to >= 2.
static func spawn(parent: Node, base_position: Vector2, height_tiles: int = DEFAULT_HEIGHT_TILES) -> LadderZone:
	if parent == null:
		push_error("LadderFactory.spawn: parent is null")
		return null

	var ladder: LadderZone = LADDER_SCENE.instantiate() as LadderZone
	if ladder == null:
		push_error("LadderFactory.spawn: failed to instantiate ladder.tscn")
		return null

	ladder.height_tiles = maxi(height_tiles, MIN_HEIGHT_TILES)
	ladder.position = base_position
	parent.add_child(ladder)
	return ladder


## World Y for a surface row helper — place ladder base on this Y.
static func tile_height_px(height_tiles: int) -> float:
	return float(maxi(height_tiles, MIN_HEIGHT_TILES) * KenneyPlatformTiles.TILE_SIZE)
