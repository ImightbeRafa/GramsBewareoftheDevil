class_name CaneVisual
extends Node2D

const POGO_COLOR: Color = Color(0.3, 0.85, 0.5, 1.0)
const HOOK_COLOR: Color = Color(0.95, 0.8, 0.2, 1.0)
const SMASH_COLOR: Color = Color(0.9, 0.35, 0.25, 1.0)

var _player: Player
var _hook: CaneHook
var _pogo: CanePogo
var _smash: CaneSmash
var _aim_line: Line2D
var _cane_stick: Line2D
var _hook_target_ring: Line2D
var _pulse_timer: float = 0.0
var _action_flash: float = 0.0


func setup(
	player: Player,
	smash: CaneSmash = null,
	hook: CaneHook = null,
	pogo: CanePogo = null
) -> void:
	_player = player
	_smash = smash
	_hook = hook
	_pogo = pogo
	_aim_line = Line2D.new()
	_aim_line.width = 2.0
	_aim_line.default_color = HOOK_COLOR
	_aim_line.visible = false
	add_child(_aim_line)

	_cane_stick = Line2D.new()
	_cane_stick.width = 3.0
	_cane_stick.default_color = POGO_COLOR
	_cane_stick.visible = false
	add_child(_cane_stick)

	_hook_target_ring = Line2D.new()
	_hook_target_ring.width = 2.0
	_hook_target_ring.default_color = HOOK_COLOR
	_hook_target_ring.visible = false
	add_child(_hook_target_ring)


func flash_action(mode: int) -> void:
	_action_flash = 0.2
	match mode:
		0:
			_cane_stick.default_color = POGO_COLOR.lightened(0.3)
		1:
			_aim_line.default_color = HOOK_COLOR.lightened(0.4)
		2:
			_cane_stick.default_color = SMASH_COLOR.lightened(0.3)


func flash_miss() -> void:
	_action_flash = 0.15
	_aim_line.default_color = Color(0.9, 0.3, 0.3, 0.8)


func process_visual(delta: float) -> void:
	_pulse_timer += delta
	if _action_flash > 0.0:
		_action_flash = maxf(_action_flash - delta, 0.0)

	if _hook != null and _hook.is_hooking():
		process_hooking_visual(delta)
		return

	_aim_line.visible = false
	_cane_stick.visible = false
	_hook_target_ring.visible = false

	if _player.unlocks == null:
		return

	match _player.cane_mode:
		0:
			_draw_pogo_cane()
		1:
			_draw_hook_aim()
		2:
			_draw_smash_cane()


func process_hooking_visual(_delta: float) -> void:
	if _hook == null:
		return
	var anchor := _hook.get_hook_anchor()
	if anchor == Vector2.ZERO:
		return
	var local_anchor := anchor - _player.global_position
	_aim_line.visible = true
	_aim_line.default_color = HOOK_COLOR.lightened(0.2)
	_aim_line.points = PackedVector2Array([Vector2.ZERO, local_anchor])
	_cane_stick.visible = true
	_cane_stick.default_color = HOOK_COLOR
	_cane_stick.points = PackedVector2Array([Vector2.ZERO, local_anchor * 0.85])


func _draw_pogo_cane() -> void:
	if not _player.unlocks.cane_pogo:
		return
	if _player.is_on_floor():
		return
	var aim := Vector2(0.0, 1.0)
	if _pogo != null:
		aim = _pogo.get_pogo_aim()
	_cane_stick.visible = true
	var valid := _pogo == null or _pogo.is_pogo_aim_valid()
	_cane_stick.default_color = POGO_COLOR if valid else Color(0.55, 0.55, 0.55, 0.7)
	if _action_flash > 0.0:
		_cane_stick.default_color = POGO_COLOR.lightened(0.35)
	var extend := 22.0 + sin(_pulse_timer * 12.0) * 2.0 if CaneInput.is_use_pressed() else 16.0
	_cane_stick.points = PackedVector2Array([Vector2(0.0, -4.0), aim * extend])


func _draw_hook_aim() -> void:
	if not _player.unlocks.cane_hook:
		return
	var aim := _get_aim_direction()
	var range := 170.0
	_aim_line.visible = true
	_aim_line.points = PackedVector2Array([Vector2.ZERO, aim * range])
	_aim_line.default_color = HOOK_COLOR if _action_flash <= 0.0 else HOOK_COLOR.lightened(0.45)

	if _hook != null:
		var target := _hook.find_best_hook_point(aim, range)
		if target != null:
			var local_target := target.global_position - _player.global_position
			_hook_target_ring.visible = true
			_draw_ring(local_target, 10.0)


func _draw_smash_cane() -> void:
	if not _player.unlocks.cane_smash:
		return
	_cane_stick.visible = true
	_cane_stick.default_color = SMASH_COLOR
	var direction := Vector2(_player.facing_direction, -0.2).normalized()
	if _smash != null:
		direction = _smash.get_aim_direction()
	var length := 18.0
	if _smash != null and _smash.is_charging():
		length = 26.0 + sin(_pulse_timer * 16.0) * 3.0
		_cane_stick.default_color = SMASH_COLOR.lightened(0.25)
	_cane_stick.points = PackedVector2Array([Vector2(0.0, -8.0), direction * length])


func _get_aim_direction() -> Vector2:
	var mouse_pos := _player.get_global_mouse_position()
	var direction := mouse_pos - _player.global_position
	if direction.length_squared() < 16.0:
		return Vector2(_player.facing_direction, -0.6).normalized()
	return direction.normalized()


func _draw_ring(center: Vector2, radius: float) -> void:
	var points: PackedVector2Array = PackedVector2Array()
	for i in range(13):
		var angle := float(i) / 12.0 * TAU
		points.append(center + Vector2(cos(angle), sin(angle)) * radius)
	_hook_target_ring.points = points
