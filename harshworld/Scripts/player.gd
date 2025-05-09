extends CharacterBody2D

@export var speed: float = 150.0
@export var acceleration: float = 15.0
@export var friction: float = 10.0

var input_direction: Vector2 = Vector2.ZERO
var current_weapon: Node = null  # ✅ Declare the missing variable here

func _ready():
	z_index = 10  # Higher than chunks (default is 0)
	equip_weapon("Sword")  # Example for startup

func _process(_delta):
	var mouse_global = get_global_mouse_position()
	var to_mouse = mouse_global - global_position
	var max_radius = 32.0  # Weapon stays within this radius

	# Clamp the weapon's position within a circle around the player
	var clamped_position = to_mouse.limit_length(max_radius)
	$WeaponHolder.position = clamped_position

	# Make the weapon face the mouse
	$WeaponHolder.rotation = to_mouse.angle()






func equip_weapon(weapon_name: String):
	if current_weapon:
		current_weapon.queue_free()
	
	var weapon_scene = load("res://Scenes/Weapon.tscn")
	current_weapon = weapon_scene.instantiate()
	$WeaponHolder.add_child(current_weapon)
	
	# Ensure the weapon has the attack method
	if current_weapon.has_method("attack"):
		print("Weapon equipped: %s" % weapon_name)
	else:
		print("Warning: No 'attack' method in weapon %s" % weapon_name)

	
	
func _unhandled_input(event):
	if event.is_action_pressed("attack") and current_weapon:
		if current_weapon.has_method("attack"):
			current_weapon.attack()


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
