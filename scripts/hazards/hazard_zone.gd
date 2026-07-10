class_name HazardZone
extends Area2D

enum DamageMode { INSTANT_KILL, DOT }


@export var damage_mode: DamageMode = DamageMode.INSTANT_KILL
@export var damage_per_second: float = 40.0
@export var tick_interval: float = 0.25
@export var lethal_after_seconds: float = 2.5

var _tracked_players: Dictionary = {}


func _ready() -> void:
	add_to_group("hazard")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if damage_mode == DamageMode.DOT:
		set_process(true)


func _process(delta: float) -> void:
	if damage_mode != DamageMode.DOT:
		return
	var to_remove: Array[Player] = []
	for body: Player in _tracked_players.keys():
		if not is_instance_valid(body):
			to_remove.append(body)
			continue
		if body.has_method("is_bracing") and body.is_bracing():
			continue
		var elapsed: float = _tracked_players[body] + delta
		_tracked_players[body] = elapsed
		if elapsed >= lethal_after_seconds:
			_kill_player(body)
			to_remove.append(body)
	for body in to_remove:
		_tracked_players.erase(body)


func _on_body_entered(body: Node2D) -> void:
	if not (body is Player):
		return
	var player := body as Player
	if not _can_hurt(player):
		return
	if damage_mode == DamageMode.INSTANT_KILL:
		_kill_player(player)
	elif damage_mode == DamageMode.DOT:
		_tracked_players[player] = 0.0
		if player.has_method("apply_toxic"):
			player.apply_toxic(true)


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		_tracked_players.erase(body)
		if body.has_method("apply_toxic"):
			body.apply_toxic(false)


func _can_hurt(player: Player) -> bool:
	if player.has_method("is_pogo_iframe_active") and player.is_pogo_iframe_active():
		return false
	if player.has_method("is_bracing") and player.is_bracing():
		return false
	var controller: Node = get_tree().get_first_node_in_group("level_controller")
	if controller != null and controller.has_method("is_playing") and not controller.is_playing():
		return false
	return true


func _kill_player(player: Player) -> void:
	if player.has_method("die"):
		player.die()
	else:
		var controller: Node = get_tree().get_first_node_in_group("level_controller")
		if controller != null and controller.has_method("on_player_died"):
			controller.on_player_died()
