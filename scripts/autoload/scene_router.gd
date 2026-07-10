extends Node

const PATH_PARKOUR: String = "res://scenes/levels/parkour_test.tscn"
const PATH_LEVEL_01: String = "res://scenes/levels/level_01.tscn"
const PATH_SHIFTING: String = "res://scenes/levels/shifting_map.tscn"

var _changing: bool = false


func go_to_parkour() -> void:
	_change_scene(PATH_PARKOUR)


func go_to_level_01() -> void:
	_change_scene(PATH_LEVEL_01)


func go_to_shifting() -> void:
	_change_scene(PATH_SHIFTING)


func get_current_scene_path() -> String:
	var scene := get_tree().current_scene
	if scene == null:
		return ""
	return scene.scene_file_path


func _change_scene(path: String) -> void:
	if _changing:
		return
	if get_current_scene_path() == path:
		return
	if not ResourceLoader.exists(path):
		push_error("SceneRouter: missing scene at %s" % path)
		return
	_changing = true
	call_deferred("_deferred_change", path)


func _deferred_change(path: String) -> void:
	var tree := get_tree()
	if tree == null:
		_changing = false
		return
	var error := tree.change_scene_to_file(path)
	_changing = false
	if error != OK:
		push_error("SceneRouter: failed to load %s (error %d)" % [path, error])
