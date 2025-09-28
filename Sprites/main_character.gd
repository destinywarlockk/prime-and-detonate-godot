extends CharacterBody2D

# Movement variables
@export var speed: float = 200.0
@export var sprint_multiplier: float = 1.5
@export var jump_force: float = -400.0
@export var gravity: float = 980.0

# Physics state
var is_on_ground: bool = false

func _physics_process(delta):
	handle_movement()
	handle_jumping()
	apply_gravity(delta)
	apply_movement()

func handle_movement():
	var input_vector = Vector2.ZERO
	
	# WASD movement
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		input_vector.x += 1
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		input_vector.x -= 1
	if Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
		input_vector.y += 1
	if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W):
		input_vector.y -= 1
	
	# Normalize diagonal movement
	if input_vector.length() > 0:
		input_vector = input_vector.normalized()
	
	# Apply sprint multiplier if shift is held
	var current_speed = speed
	if Input.is_key_pressed(KEY_SHIFT):
		current_speed *= sprint_multiplier
	
	# Set horizontal velocity
	velocity.x = input_vector.x * current_speed

func handle_jumping():
	# Jump if space is pressed and character is on ground
	if Input.is_action_just_pressed("ui_accept") or Input.is_key_pressed(KEY_SPACE):
		if is_on_ground:
			velocity.y = jump_force

func apply_gravity(delta):
	# Apply gravity when not on ground
	if not is_on_ground:
		velocity.y += gravity * delta

func apply_movement():
	# Move and slide for collision detection
	move_and_slide()
	
	# Update ground state
	is_on_ground = is_on_floor()
	
	# Reset vertical velocity if on ground
	if is_on_ground and velocity.y > 0:
		velocity.y = 0
