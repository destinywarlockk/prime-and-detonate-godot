extends Node2D
class_name HoverMotion

@export var hover_height: float = 20.0
@export var hover_speed: float = 2.0
@export var hover_delay: float = 0.0

var original_position: Vector2
var hover_tween: Tween
var parent_enemy: Node2D

func _ready():
	# Get the parent enemy node
	parent_enemy = get_parent()
	
	# Store the original position
	original_position = parent_enemy.global_position
	
	# Start hover animation after delay
	if hover_delay > 0:
		await get_tree().create_timer(hover_delay).timeout
	
	_start_hover_animation()

func _start_hover_animation():
	# Create a continuous hover motion
	var top_position = original_position + Vector2(0, -hover_height)
	var bottom_position = original_position + Vector2(0, hover_height)
	
	# Start at top position
	parent_enemy.global_position = top_position
	
	# Create tween for continuous hover motion
	hover_tween = create_tween()
	hover_tween.set_loops()
	
	# Move down to bottom
	hover_tween.tween_property(parent_enemy, "global_position", bottom_position, hover_speed)
	# Move back up to top
	hover_tween.tween_property(parent_enemy, "global_position", top_position, hover_speed)

func stop_hover():
	if hover_tween:
		hover_tween.kill()
		hover_tween = null
	# Return to original position
	parent_enemy.global_position = original_position

func resume_hover():
	if not hover_tween:
		_start_hover_animation()
