class_name CrumblingPlatform
extends StaticBody2D

@export var crumble_delay: float = 0.4
@export var shake_duration: float = 0.25
@export var gone_duration: float = 1.5

var _timer: float = 0.0
var _state: int = 0
var _collision: CollisionShape2D
var _visual: CanvasItem
var _original_position: Vector2


func _ready() -> void:
	add_to_group("parkour_platform")
	_collision = $CollisionShape2D
	_original_position = position
	_replace_visual()
	var detect_area: Area2D = $DetectArea
	detect_area.body_entered.connect(_on_body_entered)


func _replace_visual() -> void:
	var color_rect := get_node_or_null("ColorRect") as ColorRect
	if color_rect != null:
		color_rect.queue_free()
	var sprite := PlatformVisual.create_surface_sprite(3.0)
	sprite.modulate = Color(1.0, 0.92, 0.85, 1.0)
	add_child(sprite)
	_visual = sprite


func _on_body_entered(body: Node2D) -> void:
	if body is Player and _state == 0:
		_state = 1
		_timer = crumble_delay


var _shift_paused: bool = false


func pause_for_shift(paused: bool) -> void:
	_shift_paused = paused


func _physics_process(delta: float) -> void:
	if _shift_paused or _state == 0:
		return

	_timer -= delta
	match _state:
		1:
			if _timer <= 0.0:
				_state = 2
				_timer = shake_duration
		2:
			position.x = _original_position.x + sin(_timer * 60.0) * 2.0
			if _timer <= 0.0:
				_state = 3
				_collision.disabled = true
				if _visual != null:
					_visual.modulate.a = 0.3
				_timer = gone_duration
		3:
			if _timer <= 0.0:
				_state = 0
				position = _original_position
				_collision.disabled = false
				if _visual != null:
					_visual.modulate.a = 1.0
