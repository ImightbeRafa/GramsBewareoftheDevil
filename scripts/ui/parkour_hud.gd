extends CanvasLayer

var _player: Player
var _controller: ShiftingMapController
@onready var _status_label: Label = $MarginContainer/VBox/StatusLabel
var _shift_label: Label

const LAYOUT_NAMES: Array[String] = [
	"Pulse Bridge",
	"Toxic Shelf",
	"Clock Shaft",
	"Orb Line",
]


func _ready() -> void:
	_shift_label = get_node_or_null("MarginContainer/VBox/ShiftLabel") as Label
	call_deferred("_bind_nodes")


func _bind_nodes() -> void:
	_player = get_tree().get_first_node_in_group("player") as Player
	_controller = get_tree().get_first_node_in_group("shifting_map_controller") as ShiftingMapController


func _process(_delta: float) -> void:
	if _player == null:
		_player = get_tree().get_first_node_in_group("player") as Player
	if _controller == null:
		_controller = get_tree().get_first_node_in_group("shifting_map_controller") as ShiftingMapController
	if _status_label == null:
		return

	if _controller != null:
		_update_shifting_hud()
	else:
		_status_label.text = "CP %s · O=shift map · P=parkour" % _cp_text()
		if _shift_label != null:
			_shift_label.text = ""


func _update_shifting_hud() -> void:
	var layout_idx: int = _controller.current_layout
	var layout_name: String = LAYOUT_NAMES[layout_idx] if layout_idx < LAYOUT_NAMES.size() else str(layout_idx)
	var state_tag := _state_tag()
	_status_label.text = "L%d %s%s · CP%s · %s" % [
		layout_idx,
		layout_name,
		state_tag,
		_cp_text(),
		_ability_tags(),
	]
	if _shift_label == null:
		return
	if _controller.is_frozen():
		_shift_label.text = "Frozen — release E"
	elif _controller.get_state() == ShiftingMapController.State.WARNING:
		_shift_label.text = "Shift %.1fs — reach safe ground" % _controller.get_time_until_shift()
	elif _controller.get_state() == ShiftingMapController.State.SHIFTING:
		_shift_label.text = "Shifting — blocks vanish"
	else:
		var cd: float = _controller.get_freeze_cooldown_remaining()
		var cd_text: String = " · freeze CD %.0fs" % cd if cd > 0.0 else ""
		_shift_label.text = "Next %.1fs · E=freeze · layout %s%s" % [
			_controller.get_time_until_shift(),
			_layout_letter(layout_idx),
			cd_text,
		]


func _state_tag() -> String:
	match _controller.get_state():
		ShiftingMapController.State.WARNING:
			return " !"
		ShiftingMapController.State.SHIFTING:
			return " ~"
		ShiftingMapController.State.FROZEN:
			return " *"
		_:
			return ""


func _cp_text() -> String:
	return str(_player.checkpoint_id) if _player != null else "—"


func _ability_tags() -> String:
	if _player == null:
		return "—"
	var dash := "dash" if not _player.is_dashing() else "DASH"
	var glide := "glide" if _player.is_gliding() else ""
	return "%s%s" % [dash, " · " + glide if glide != "" else ""]


func _layout_letter(idx: int) -> String:
	match idx:
		0:
			return "A"
		1:
			return "B"
		2:
			return "C"
		3:
			return "D"
		_:
			return "?"
