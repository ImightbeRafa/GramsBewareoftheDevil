class_name CrouchVisual
extends Node2D

## Drawn squat/slide silhouette — Kenney atlas has no crouch frames.

const STAND_COLOR := Color(0.35, 0.82, 0.55, 1.0)
const HELMET_COLOR := Color(0.92, 0.95, 1.0, 1.0)
const SLIDE_COLOR := Color(0.28, 0.72, 0.95, 1.0)
const SLIDE_HELMET := Color(0.82, 0.92, 1.0, 1.0)

var _active: bool = false
var _sliding: bool = false
var _facing: float = 1.0


func set_state(active: bool, sliding: bool, facing: float) -> void:
	_active = active
	_sliding = sliding
	_facing = facing
	visible = active
	queue_redraw()


func _draw() -> void:
	if not _active:
		return

	var face := 1.0 if _facing >= 0.0 else -1.0
	if _sliding:
		_draw_slide(face)
	else:
		_draw_crouch(face)


func _draw_crouch(face: float) -> void:
	# Body — wide squat block, feet near y = 0
	draw_rect(Rect2(-14.0, -20.0, 28.0, 14.0), STAND_COLOR)
	draw_rect(Rect2(-12.0, -22.0, 24.0, 4.0), STAND_COLOR.darkened(0.12))
	# Helmet dome
	draw_circle(Vector2(2.0 * face, -26.0), 9.0, HELMET_COLOR)
	draw_rect(Rect2(-9.0, -26.0, 18.0, 6.0), HELMET_COLOR)
	# Eye visor hint
	draw_rect(Rect2(4.0 * face, -27.0, 5.0 * face, 3.0), Color(0.15, 0.2, 0.25, 0.55))


func _draw_slide(face: float) -> void:
	# Low horizontal profile
	draw_rect(Rect2(-16.0 * face, -14.0, 32.0 * face, 10.0), SLIDE_COLOR)
	draw_circle(Vector2(10.0 * face, -16.0), 8.0, SLIDE_HELMET)
	draw_rect(Rect2(-4.0 * face, -17.0, 16.0 * face, 5.0), SLIDE_HELMET)
	# Motion streaks
	draw_line(Vector2(-22.0 * face, -8.0), Vector2(-30.0 * face, -8.0), SLIDE_COLOR.lightened(0.35), 2.0)
	draw_line(Vector2(-20.0 * face, -12.0), Vector2(-28.0 * face, -12.0), SLIDE_COLOR.lightened(0.25), 1.5)
