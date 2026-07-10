class_name LevelController
extends Node

enum State { PLAYING, COMPLETED }

var _state: State = State.PLAYING
var _complete_panel: Control
var _restart_button: Button
var _hint_label: Label


func _ready() -> void:
	add_to_group("level_controller")
	_resolve_ui_nodes()
	if _restart_button != null:
		_restart_button.pressed.connect(_on_restart_pressed)
	if _complete_panel != null:
		_complete_panel.visible = false
	set_process_unhandled_input(true)


func _resolve_ui_nodes() -> void:
	var scene_root := get_tree().current_scene
	if scene_root == null:
		return
	_hint_label = scene_root.get_node_or_null("UI/HintLabel") as Label
	_complete_panel = scene_root.get_node_or_null("UI/LevelCompletePanel") as Control
	_restart_button = scene_root.get_node_or_null(
		"UI/LevelCompletePanel/MarginContainer/VBoxContainer/RestartButton"
	) as Button


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	match event.keycode:
		KEY_P:
			SceneRouter.go_to_parkour()
		KEY_L:
			SceneRouter.go_to_level_01()
		KEY_O:
			SceneRouter.go_to_shifting()


func is_playing() -> bool:
	return _state == State.PLAYING


func on_player_died() -> void:
	if _state != State.PLAYING:
		return
	var player := get_tree().get_first_node_in_group("player") as Player
	if player != null and player.has_method("die"):
		player.die()
	else:
		restart_level()


func on_goal_reached(player: Player) -> void:
	if _state != State.PLAYING:
		return
	_state = State.COMPLETED
	player.freeze()
	if _hint_label != null:
		_hint_label.visible = false
	if _complete_panel != null:
		_complete_panel.visible = true


func restart_level() -> void:
	get_tree().reload_current_scene()


func _on_restart_pressed() -> void:
	restart_level()
