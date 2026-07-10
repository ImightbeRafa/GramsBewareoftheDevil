class_name ShiftingMapController
extends Node

enum State { STABLE, WARNING, SHIFTING, FROZEN }

signal layout_changed(layout_index: int)
signal shift_warning(seconds_remaining: float)
signal shift_started(from_layout: int, to_layout: int)
signal shift_finished(layout_index: int)
signal freeze_changed(is_frozen: bool)

@export var shift_interval: float = 8.0
@export var warning_duration: float = 1.0
@export var shift_duration: float = 1.0
@export var nudge_fraction: float = 0.45
@export var unfreeze_timer_fraction: float = 0.5
@export var freeze_cooldown: float = 3.0

var current_layout: int = 0

var _state: State = State.STABLE
var _timer: float = 0.0
var _warning_timer: float = 0.0
var _freeze_cooldown_timer: float = 0.0
var _blocks: Array[ShiftingBlock] = []


func _ready() -> void:
	add_to_group("shifting_map_controller")
	_timer = shift_interval


func register_blocks(blocks: Array[ShiftingBlock]) -> void:
	_blocks = blocks
	for block in _blocks:
		block.snap_to_pose(current_layout)


func _process(delta: float) -> void:
	if _freeze_cooldown_timer > 0.0:
		_freeze_cooldown_timer = maxf(_freeze_cooldown_timer - delta, 0.0)

	match _state:
		State.STABLE:
			_timer -= delta
			if _timer <= 0.0:
				_begin_warning()
		State.WARNING:
			_warning_timer -= delta
			shift_warning.emit(maxf(_warning_timer, 0.0))
			if _warning_timer <= 0.0:
				_state = State.SHIFTING
				_execute_shift()


func get_state() -> State:
	return _state


func is_shifting() -> bool:
	return _state == State.SHIFTING


func is_frozen() -> bool:
	return _state == State.FROZEN


func get_time_until_shift() -> float:
	if _state == State.FROZEN:
		return _timer
	if _state == State.WARNING:
		return _warning_timer
	return _timer


func get_freeze_cooldown_remaining() -> float:
	return _freeze_cooldown_timer


func request_shift(_source: StringName = &"") -> bool:
	return nudge_shift_timer()


func nudge_shift_timer() -> bool:
	if _state == State.FROZEN or _state == State.SHIFTING:
		return false
	if _state == State.STABLE:
		_timer = minf(_timer, shift_interval * nudge_fraction)
		if _timer <= 0.05:
			_begin_warning()
		return true
	if _state == State.WARNING:
		_warning_timer = minf(_warning_timer, warning_duration * nudge_fraction)
		return true
	return false


func request_freeze() -> bool:
	if _state == State.SHIFTING:
		return false
	if _freeze_cooldown_timer > 0.0:
		return false
	if _state == State.FROZEN:
		return true

	if _state == State.WARNING:
		_warning_timer = 0.0

	_state = State.FROZEN
	_pause_child_movers(true)
	freeze_changed.emit(true)
	return true


func request_unfreeze() -> void:
	if _state != State.FROZEN:
		return
	_state = State.STABLE
	_timer = shift_interval * unfreeze_timer_fraction
	_pause_child_movers(false)
	_freeze_cooldown_timer = freeze_cooldown
	freeze_changed.emit(false)


func _begin_warning() -> void:
	if _state == State.FROZEN:
		return
	_state = State.WARNING
	_warning_timer = warning_duration
	shift_warning.emit(_warning_timer)


func _execute_shift() -> void:
	var from_layout := current_layout
	var to_layout := (current_layout + 1) % 4
	_pause_child_movers(true)
	_detach_players_on_blocks()
	_set_blocks_touchable(false)
	shift_started.emit(from_layout, to_layout)

	var tweens: Array[Tween] = []
	for block in _blocks:
		var tween := block.tween_to_pose(to_layout, shift_duration)
		if tween != null:
			tweens.append(tween)

	if not tweens.is_empty():
		await get_tree().create_timer(shift_duration).timeout

	current_layout = to_layout
	for block in _blocks:
		block.snap_to_pose(current_layout)
	_set_blocks_touchable(true)
	_pause_child_movers(false)
	_state = State.STABLE
	_timer = shift_interval
	layout_changed.emit(current_layout)
	shift_finished.emit(current_layout)


func _set_blocks_touchable(enabled: bool) -> void:
	for block in _blocks:
		block.set_touchable(enabled)


func _detach_players_on_blocks() -> void:
	var player := get_tree().get_first_node_in_group("player") as Player
	if player == null:
		return
	if not player.is_on_floor():
		return
	for i in player.get_slide_collision_count():
		var collision := player.get_slide_collision(i)
		var collider := collision.get_collider()
		if collider is ShiftingBlock:
			player.velocity.y = maxf(player.velocity.y, 120.0)
			return


func _pause_child_movers(paused: bool) -> void:
	for node in get_tree().get_nodes_in_group("moving_platform"):
		if node.has_method("pause_for_shift"):
			node.pause_for_shift(paused)
	for node in get_tree().get_nodes_in_group("parkour_platform"):
		if node.has_method("pause_for_shift"):
			node.pause_for_shift(paused)
	for node in get_tree().get_nodes_in_group("fire_orb"):
		if node.has_method("pause_for_shift"):
			node.pause_for_shift(paused)
