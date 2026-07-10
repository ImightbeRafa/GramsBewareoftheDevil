class_name ParallaxSky
extends Node2D

@export var sky_color: Color = Color(0.42, 0.68, 0.92, 1.0)
@export var hill_far_color: Color = Color(0.32, 0.52, 0.36, 1.0)
@export var hill_near_color: Color = Color(0.38, 0.62, 0.4, 1.0)
@export var cloud_color: Color = Color(1.0, 1.0, 1.0, 0.28)
@export var band_width: float = 4000.0
@export var band_height: float = 900.0


func _ready() -> void:
	z_index = -100
	set_process(true)


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	var camera := get_viewport().get_camera_2d()
	if camera == null:
		return

	var cam_pos := camera.global_position
	var origin := cam_pos - global_position

	# Sky (moves slowest)
	var sky_origin := origin * 0.12
	draw_rect(
		Rect2(sky_origin.x - band_width, sky_origin.y - 80.0, band_width * 2.0, band_height * 0.55),
		sky_color
	)

	# Far hills
	var far_origin := origin * 0.28
	draw_rect(
		Rect2(far_origin.x - band_width, far_origin.y + band_height * 0.28, band_width * 2.0, band_height * 0.22),
		hill_far_color
	)

	# Near hills
	var near_origin := origin * 0.45
	draw_rect(
		Rect2(near_origin.x - band_width, near_origin.y + band_height * 0.42, band_width * 2.0, band_height * 0.2),
		hill_near_color
	)

	# Simple clouds
	var cloud_origin := origin * 0.2
	for i in range(8):
		var cloud_x := cloud_origin.x + float(i) * 360.0 - 600.0
		var cloud_y := cloud_origin.y + 60.0 + float(i % 3) * 40.0
		draw_rect(Rect2(cloud_x, cloud_y, 100.0 + float(i % 2) * 30.0, 24.0), cloud_color)
