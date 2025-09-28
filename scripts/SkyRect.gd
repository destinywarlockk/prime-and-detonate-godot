extends Node2D
class_name SkyRect

@export var height_ratio: float = 1.0 # Fill entire screen
@export var color: Color = Color(0, 0, 0, 1)

func _ready() -> void:
	# Ensure we redraw on resize (viewport changes)
	get_viewport().size_changed.connect(queue_redraw)
	queue_redraw()

func _draw() -> void:
	var vp_size: Vector2 = get_viewport_rect().size
	var rect_size: Vector2 = Vector2(vp_size.x, vp_size.y * clamp(height_ratio, 0.0, 1.0))
	# Draw from origin to fill entire screen
	var start_pos: Vector2 = -global_position
	draw_rect(Rect2(start_pos, rect_size), color, true)
