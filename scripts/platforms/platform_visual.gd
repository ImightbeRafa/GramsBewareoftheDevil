class_name PlatformVisual
extends RefCounted

const TILE_TEXTURE: Texture2D = preload("res://assets/placeholders/kenney/tiles_packed.png")
const TILE_SIZE: int = KenneyPlatformTiles.TILE_SIZE


static func build_platform_node(
	width_tiles: float,
	height_tiles: float = 1.0,
	tint: Color = Color.WHITE
) -> Node2D:
	var root := Node2D.new()
	var width := maxi(int(roundf(width_tiles)), 1)
	var height := maxi(int(roundf(height_tiles)), 1)
	var tile_size := float(TILE_SIZE)
	var width_px := float(width) * tile_size
	var height_px := float(height) * tile_size

	for x in range(width):
		for y in range(height):
			var atlas := _atlas_for_cell(x, y, width, height)
			var sprite := _make_tile_sprite(atlas)
			sprite.modulate = tint
			sprite.position = Vector2(
				-width_px * 0.5 + float(x) * tile_size + tile_size * 0.5,
				-height_px + float(y) * tile_size + tile_size * 0.5
			)
			root.add_child(sprite)
	return root


static func create_surface_sprite(width_tiles: float = 3.0) -> Node2D:
	return build_platform_node(width_tiles, 1.0, Color.WHITE)


static func _atlas_for_cell(x: int, y: int, width: int, height: int) -> Vector2i:
	var is_top := y == 0
	var is_bottom := y == height - 1
	var is_left := x == 0
	var is_right := x == width - 1

	if is_top:
		if width == 1:
			return KenneyPlatformTiles.ATLAS_TOP_MID
		if is_left:
			return KenneyPlatformTiles.ATLAS_TOP_LEFT
		if is_right:
			return KenneyPlatformTiles.ATLAS_TOP_RIGHT
		return KenneyPlatformTiles.ATLAS_TOP_MID

	if is_bottom and height > 1:
		if width == 1:
			return KenneyPlatformTiles.ATLAS_MID
		if is_left:
			return KenneyPlatformTiles.ATLAS_MID_LEFT
		if is_right:
			return KenneyPlatformTiles.ATLAS_MID_RIGHT
		return KenneyPlatformTiles.ATLAS_MID

	if width == 1:
		return KenneyPlatformTiles.ATLAS_MID
	if is_left:
		return KenneyPlatformTiles.ATLAS_MID_LEFT
	if is_right:
		return KenneyPlatformTiles.ATLAS_MID_RIGHT
	return KenneyPlatformTiles.ATLAS_MID


static func _make_tile_sprite(atlas: Vector2i) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.texture = TILE_TEXTURE
	sprite.region_enabled = true
	var ts := float(TILE_SIZE)
	sprite.region_rect = Rect2(
		float(atlas.x) * ts,
		float(atlas.y) * ts,
		ts,
		ts
	)
	return sprite
