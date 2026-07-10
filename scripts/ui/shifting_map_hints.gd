extends CanvasLayer

@export var hint_duration: float = 2.5

var _label: Label
var _timer: float = 0.0
var _controller: ShiftingMapController
var _player: Player
var _shown_spawn: bool = false
var _shown_warning: bool = false


func _ready() -> void:
	_label = Label.new()
	_label.visible = false
	_label.add_theme_font_size_override("font_size", 13)
	_label.add_theme_color_override("font_color", Color(0.95, 0.93, 0.86, 1))
	_label.add_theme_color_override("font_outline_color", Color(0.05, 0.06, 0.1, 0.9))
	_label.add_theme_constant_override("outline_size", 2)
	_label.offset_left = 16.0
	_label.offset_top = 52.0
	_label.offset_right = 420.0
	add_child(_label)
	call_deferred("_bind")


func _bind() -> void:
	_controller = get_tree().get_first_node_in_group("shifting_map_controller") as ShiftingMapController
	_player = get_tree().get_first_node_in_group("player") as Player
	if _controller != null:
		_controller.shift_warning.connect(_on_shift_warning)
		_controller.shift_started.connect(_on_shift_started)
		_controller.freeze_changed.connect(_on_freeze_changed)
	await get_tree().create_timer(0.6).timeout
	if not _shown_spawn:
		show_hint("Bay 0: bridge only on layout A/C — freeze (E) to cross on other layouts.")
		_shown_spawn = true


func _process(delta: float) -> void:
	if _timer <= 0.0:
		return
	_timer -= delta
	if _timer <= 0.0:
		_label.visible = false


func show_hint(text: String) -> void:
	_label.text = text
	_label.visible = true
	_timer = hint_duration


func _on_shift_warning(_seconds: float) -> void:
	if _shown_warning:
		return
	show_hint("Warning — shifting blocks drop away. Jump to solid ground!")
	_shown_warning = true


func _on_shift_started(_from: int, _to: int) -> void:
	show_hint("Blocks untouchable — don't land on empty air.")


func _on_freeze_changed(frozen: bool) -> void:
	if frozen:
		show_hint("Layout frozen. Release E when ready to resume timer.")
	else:
		show_hint("Timer resumed — next shift soon.")
