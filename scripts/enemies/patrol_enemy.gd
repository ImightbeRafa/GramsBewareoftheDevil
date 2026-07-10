extends Node2D
class_name PatrolEnemy

@export var patrol_distance: float = 70.0
@export var patrol_speed: float = 55.0

var _origin_x: float
var _direction: float = 1.0

@onready var _area: Area2D = $Area2D
@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	add_to_group("pogo_target")
	_origin_x = position.x
	_area.body_entered.connect(_on_body_entered)
	_sprite.play("walk")


func on_pogo_hit() -> void:
	queue_free()


func on_smash_hit() -> void:
	queue_free()


func _physics_process(delta: float) -> void:
	position.x += patrol_speed * _direction * delta
	_sprite.flip_h = _direction < 0.0
	if absf(position.x - _origin_x) >= patrol_distance:
		_direction *= -1.0


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		if body.is_pogo_iframe_active() or body.is_sliding():
			return
		var controller: Node = get_tree().get_first_node_in_group("level_controller")
		if controller != null and controller.has_method("is_playing") and not controller.is_playing():
			return
		if body.has_method("die"):
			body.die()
		elif controller != null and controller.has_method("on_player_died"):
			controller.on_player_died()
		else:
			get_tree().reload_current_scene()
