class_name LadderAbility
extends Node

@export var climb_speed: float = 260.0
@export var side_move_speed: float = 140.0
@export var grip_release_margin: float = 4.0
@export var mount_align_x: float = 16.0
@export var dismount_jump_velocity: float = -555.0
@export var jump_off_horizontal: float = 110.0
@export var mount_from_air: bool = true
@export var dismount_cooldown_time: float = 0.16
@export var top_exit_cooldown_time: float = 0.28
@export var side_exit_cooldown_time: float = 0.22
@export var mount_grace_time: float = 0.12

var _player: Player
var _overlapping: Array[LadderZone] = []
var _active_zone: LadderZone
var _mounted: bool = false
var _dismount_cooldown: float = 0.0
var _mount_grace: float = 0.0


func setup(player: Player) -> void:
	_player = player


func reset_state() -> void:
	_overlapping.clear()
	_active_zone = null
	_mounted = false
	_dismount_cooldown = 0.0
	_mount_grace = 0.0


func is_climbing() -> bool:
	return _mounted


func is_near_ladder() -> bool:
	return not _overlapping.is_empty()


func wants_climb_intent() -> bool:
	return not is_zero_approx(Input.get_axis("move_up", "move_down"))


func register_zone(zone: LadderZone) -> void:
	if zone == null or zone in _overlapping:
		return
	_overlapping.append(zone)
	if not _mounted:
		_try_mount()


func unregister_zone(zone: LadderZone) -> void:
	_overlapping.erase(zone)
	if _active_zone == zone:
		_active_zone = null
		if _mounted:
			_lose_grip(Input.get_axis("move_left", "move_right") * side_move_speed)


func cancel_for_dash() -> void:
	if _mounted:
		dismount()


func process(delta: float) -> void:
	if _dismount_cooldown > 0.0:
		_dismount_cooldown = maxf(_dismount_cooldown - delta, 0.0)
	if _mount_grace > 0.0:
		_mount_grace = maxf(_mount_grace - delta, 0.0)

	if _mounted:
		if _active_zone == null or not is_instance_valid(_active_zone):
			_lose_grip(0.0)
			return
		_process_mounted(delta)
		return

	_try_mount()


func _try_mount() -> void:
	if _dismount_cooldown > 0.0:
		return
	if _player.is_dashing() or _player.is_hooking():
		return

	var zone := _pick_best_zone()
	if zone == null:
		return

	# Must be roughly centered to grab — prevents A/D exit remount flicker.
	if absf(_player.global_position.x - zone.get_snap_x()) > mount_align_x:
		return

	var climb_intent := Input.get_axis("move_up", "move_down")
	if is_zero_approx(climb_intent):
		return

	if climb_intent > 0.0 and not zone.allows_mount_down(_player.global_position.y, _player.is_on_floor()):
		return

	if not mount_from_air and not _player.is_on_floor():
		return

	_mount(zone)


func _mount(zone: LadderZone) -> void:
	_active_zone = zone
	_mounted = true
	_mount_grace = mount_grace_time

	if _player.is_hooking():
		var hook: CaneHook = _player.get_node_or_null("CaneHook") as CaneHook
		if hook != null:
			hook.release()

	var wall: WallAbility = _player.get_node("WallAbility") as WallAbility
	if wall != null:
		wall.cancel_attachment()

	if _player.is_crouching() or _player.is_sliding():
		var crouch: CrouchAbility = _player.get_node("CrouchAbility") as CrouchAbility
		if crouch != null:
			crouch.cancel_slide()
			crouch.try_stand()

	_player.clear_jump_buffer()
	_player.velocity = Vector2.ZERO
	# Soft grab: only center when not already steering sideways (avoids ground W+A/D yank).
	var side := Input.get_axis("move_left", "move_right")
	if absf(side) < 0.2:
		_player.global_position.x = zone.get_snap_x()


func dismount() -> void:
	_mounted = false
	_active_zone = null
	_dismount_cooldown = dismount_cooldown_time
	_mount_grace = 0.0


func dismount_from_top() -> void:
	if not _mounted:
		return
	var side := Input.get_axis("move_left", "move_right")
	_mounted = false
	_active_zone = null
	_dismount_cooldown = top_exit_cooldown_time
	_mount_grace = 0.0
	_player.clear_jump_buffer()
	_player.global_position.y -= 8.0
	_player.velocity = Vector2(side * 140.0, -80.0)


func dismount_with_jump() -> void:
	if not _mounted:
		return
	var side := Input.get_axis("move_left", "move_right")
	dismount()
	_player.velocity.x = side * jump_off_horizontal
	_player.velocity.y = dismount_jump_velocity
	_player.clear_jump_buffer()


func _lose_grip(carry_x: float) -> void:
	_mounted = false
	_active_zone = null
	_dismount_cooldown = side_exit_cooldown_time
	_mount_grace = 0.0
	_player.velocity.x = carry_x
	if _player.velocity.y < 0.0:
		_player.velocity.y = 0.0


func _process_mounted(_delta: float) -> void:
	var zone := _active_zone
	if zone == null:
		_lose_grip(0.0)
		return

	if Input.is_action_just_pressed("jump"):
		dismount_with_jump()
		return

	if not zone in _overlapping:
		_lose_grip(_player.velocity.x)
		return

	var bounds := zone.get_climb_center_bounds()
	var at_top := _player.global_position.y <= bounds.x + 6.0
	var at_bottom := _player.global_position.y >= bounds.y - 6.0
	var side := Input.get_axis("move_left", "move_right")
	var climb_axis := Input.get_axis("move_up", "move_down")

	# Bottom walk-off: Down always; A/D only when NOT climbing up.
	# (W+A/D from ground used to remount-snap loop here.)
	if at_bottom and _player.is_on_floor() and _mount_grace <= 0.0:
		if climb_axis > 0.0:
			dismount()
			return
		if absf(side) > 0.2 and climb_axis >= 0.0:
			dismount()
			return

	if at_top and climb_axis < 0.0:
		dismount_from_top()
		return

	# Free hover on the ladder — no snap-back to center.
	if is_zero_approx(side):
		_player.velocity.x = 0.0
	else:
		_player.velocity.x = side * side_move_speed

	if is_zero_approx(climb_axis):
		_player.velocity.y = 0.0
	else:
		_player.velocity.y = climb_axis * climb_speed


func constrain_after_move() -> void:
	if not _mounted or _active_zone == null:
		return

	var bounds := _active_zone.get_climb_center_bounds()
	var snapped_y := clampf(_player.global_position.y, bounds.x, bounds.y)
	if not is_equal_approx(snapped_y, _player.global_position.y):
		_player.global_position.y = snapped_y
		_player.velocity.y = 0.0

	# Grace after mount: stay gripped while starting the climb (esp. from ground + A/D).
	if _mount_grace > 0.0:
		return

	var snap_x := _active_zone.get_snap_x()
	var grip_half := _active_zone.get_grip_half_width()
	var release_at := grip_half - grip_release_margin
	var offset_x := _player.global_position.x - snap_x

	if absf(offset_x) >= release_at:
		_lose_grip(_player.velocity.x)
		return


func _pick_best_zone() -> LadderZone:
	var best: LadderZone = null
	var best_dist := INF
	for zone in _overlapping:
		if zone == null or not is_instance_valid(zone):
			continue
		var dist := absf(_player.global_position.x - zone.get_snap_x())
		if dist < best_dist:
			best_dist = dist
			best = zone
	return best
