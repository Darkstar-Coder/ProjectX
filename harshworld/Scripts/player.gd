extends CharacterBody2D

@export var speed: float = 300.0
@export var acceleration: float = 15.0
@export var friction: float = 10.0

var input_direction: Vector2 = Vector2.ZERO

func _ready():
	z_index = 10  # Higher than chunks (default is 0)

func _physics_process(delta):
	# Get input
	input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down").normalized()
	
	# Apply movement
	if input_direction != Vector2.ZERO:
		velocity = velocity.lerp(input_direction * speed, acceleration * delta)
	else:
		velocity = velocity.lerp(Vector2.ZERO, friction * delta)
	
	move_and_slide()
	
	# Update chunk loader (if attached to World)
	if get_parent().has_method("update_chunks"):
		get_parent().update_chunks(global_position)
