extends Sprite2D

@export var speed: float = 200.0

func _ready():
	# Optional: Set the sprite to be centered on its position
	centered = true

func _physics_process(delta):
	handle_movement(delta)

func handle_movement(delta):
	var velocity = Vector2.ZERO
	
	# Check for input and set velocity
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		velocity.x += 1
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		velocity.x -= 1
	if Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
		velocity.y += 1
	if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W):
		velocity.y -= 1
	
	# Normalize diagonal movement to prevent faster diagonal speed
	if velocity.length() > 0:
		velocity = velocity.normalized()
		velocity *= speed
		position += velocity * delta
