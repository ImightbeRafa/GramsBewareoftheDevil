class_name KenneyPlatformTiles
extends RefCounted

const TILE_SIZE: int = 18
const TEXTURE_PATH: String = "res://assets/placeholders/kenney/tiles_packed.png"

const SURFACE_ROW: int = 35
const FILL_DEPTH: int = 3

const ATLAS_TOP_LEFT: Vector2i = Vector2i(0, 0)
const ATLAS_TOP_MID: Vector2i = Vector2i(1, 0)
const ATLAS_TOP_RIGHT: Vector2i = Vector2i(2, 0)
const ATLAS_MID_LEFT: Vector2i = Vector2i(0, 1)
const ATLAS_MID: Vector2i = Vector2i(1, 1)
const ATLAS_MID_RIGHT: Vector2i = Vector2i(2, 1)
const ATLAS_SPIKE: Vector2i = Vector2i(8, 3)
const ATLAS_FLAG: Vector2i = Vector2i(11, 5)


static func build_tileset() -> TileSet:
	var tileset := TileSet.new()
	tileset.tile_size = Vector2i(TILE_SIZE, TILE_SIZE)
	tileset.add_physics_layer()
	tileset.set_physics_layer_collision_layer(0, 1)

	var atlas := TileSetAtlasSource.new()
	atlas.texture = load(TEXTURE_PATH)
	atlas.texture_region_size = Vector2i(TILE_SIZE, TILE_SIZE)

	for coord in [
		ATLAS_TOP_LEFT,
		ATLAS_TOP_MID,
		ATLAS_TOP_RIGHT,
		ATLAS_MID_LEFT,
		ATLAS_MID,
		ATLAS_MID_RIGHT,
	]:
		atlas.create_tile(coord)

	atlas.create_tile(ATLAS_SPIKE)
	tileset.add_source(atlas, 0)

	for coord in [
		ATLAS_TOP_LEFT,
		ATLAS_TOP_MID,
		ATLAS_TOP_RIGHT,
		ATLAS_MID_LEFT,
		ATLAS_MID,
		ATLAS_MID_RIGHT,
	]:
		_register_solid_tile(atlas, coord)

	return tileset


static func _register_solid_tile(atlas: TileSetAtlasSource, coord: Vector2i) -> void:
	var tile_data := atlas.get_tile_data(coord, 0)
	tile_data.add_collision_polygon(0)
	tile_data.set_collision_polygon_points(
		0,
		0,
		PackedVector2Array([
			Vector2(0.0, 0.0),
			Vector2(float(TILE_SIZE), 0.0),
			Vector2(float(TILE_SIZE), float(TILE_SIZE)),
			Vector2(0.0, float(TILE_SIZE)),
		])
	)


static func surface_y() -> float:
	return float(SURFACE_ROW * TILE_SIZE)


static func top_atlas_for_column(tile_x: int, start_x: int, end_x: int) -> Vector2i:
	if tile_x <= start_x:
		return ATLAS_TOP_LEFT
	if tile_x >= end_x - 1:
		return ATLAS_TOP_RIGHT
	return ATLAS_TOP_MID


static func fill_atlas_for_column(tile_x: int, start_x: int, end_x: int) -> Vector2i:
	if tile_x <= start_x:
		return ATLAS_MID_LEFT
	if tile_x >= end_x - 1:
		return ATLAS_MID_RIGHT
	return ATLAS_MID
