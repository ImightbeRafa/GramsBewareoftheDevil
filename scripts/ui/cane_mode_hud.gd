extends PanelContainer

const MODE_COLORS: Array[Color] = [
	Color(0.3, 0.85, 0.5, 1.0),
	Color(0.95, 0.8, 0.2, 1.0),
	Color(0.9, 0.35, 0.25, 1.0),
]

var _player: Player
var _chip: Label


func _ready() -> void:
	_chip = Label.new()
	_chip.add_theme_font_size_override("font_size", 13)
	add_child(_chip)
	call_deferred("_bind_player")


func _bind_player() -> void:
	_player = get_tree().get_first_node_in_group("player") as Player
	if _player == null:
		return
	var controller := _player.get_node_or_null("CaneController") as CaneController
	if controller != null:
		controller.cane_mode_changed.connect(_on_mode_changed)
	_update_chip()


func _process(_delta: float) -> void:
	if _player == null:
		_player = get_tree().get_first_node_in_group("player") as Player
		if _player != null:
			_bind_player()
		return
	_update_chip()


func _on_mode_changed(_mode: int, _name: String) -> void:
	_update_chip()


func _update_chip() -> void:
	if _player == null or _chip == null:
		return
	var mode := clampi(_player.cane_mode, 0, 2)
	var names: Array[String] = ["Pogo", "Hook", "Smash"]
	var mode_name: String = names[mode]
	var color := MODE_COLORS[mode]
	_chip.text = "Cane: %s · Q cycle · LMB use" % mode_name
	_chip.add_theme_color_override("font_color", color.lightened(0.15))
