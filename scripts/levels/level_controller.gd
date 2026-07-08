class_name LevelController
extends Node

enum State { PLAYING, COMPLETED }

var _state: State = State.PLAYING

@onready var _complete_panel: Control = %LevelCompletePanel
@onready var _restart_button: Button = %RestartButton
@onready var _hint_label: Label = %HintLabel


func _ready() -> void:
	add_to_group("level_controller")
	_restart_button.pressed.connect(_on_restart_pressed)
	_complete_panel.visible = false


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
	_hint_label.visible = false
	_complete_panel.visible = true


func restart_level() -> void:
	get_tree().reload_current_scene()


func _on_restart_pressed() -> void:
	restart_level()
