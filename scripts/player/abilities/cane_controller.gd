class_name CaneController
extends Node

signal cane_mode_changed(mode: int, mode_name: String)

var _player: Player
var _pogo: CanePogo
var _hook: CaneHook
var _smash: CaneSmash
var _visual: CaneVisual


func setup(player: Player, pogo: CanePogo, hook: CaneHook, smash: CaneSmash, visual: CaneVisual = null) -> void:
	_player = player
	_pogo = pogo
	_hook = hook
	_smash = smash
	_visual = visual


func reset_state() -> void:
	_pogo.reset_state()
	_hook.reset_state()
	_smash.reset_state()


func process(delta: float) -> void:
	if Input.is_action_just_pressed("cane_mode"):
		_cycle_mode()

	if _visual != null:
		_visual.process_visual(delta)

	match _player.cane_mode:
		0:
			if _player.unlocks != null and _player.unlocks.cane_pogo:
				_pogo.process(delta)
		1:
			if _player.unlocks != null and _player.unlocks.cane_hook:
				_hook.process_input()
				_hook.process(delta)
		2:
			if _player.unlocks != null and _player.unlocks.cane_smash:
				_smash.process(delta)


func get_mode_name() -> String:
	match _player.cane_mode:
		0:
			return "Pogo"
		1:
			return "Hook"
		2:
			return "Smash"
		_:
			return "Cane"


func _cycle_mode() -> void:
	if _player.unlocks == null:
		return
	var start := _player.cane_mode
	for _i in range(3):
		_player.cane_mode = (_player.cane_mode + 1) % 3
		if _is_mode_unlocked(_player.cane_mode):
			cane_mode_changed.emit(_player.cane_mode, get_mode_name())
			return
	_player.cane_mode = start


func _is_mode_unlocked(mode: int) -> bool:
	match mode:
		0:
			return _player.unlocks.cane_pogo
		1:
			return _player.unlocks.cane_hook
		2:
			return _player.unlocks.cane_smash
	return false
