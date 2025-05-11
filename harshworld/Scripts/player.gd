extends CharacterBody2D

@onready var stat_component = $StatComponent
@onready var skill_component = $SkillComponent
@onready var mine_detector = $MineDetector

@export var speed: float = 150.0
@export var acceleration: float = 15.0
@export var friction: float = 10.0

var input_direction: Vector2 = Vector2.ZERO
var current_weapon: Node = null  # ✅ Declare the missing variable here



func _ready():
	z_index = 10  # Higher than chunks (default is 0)
	#equip_weapon("Sword")  # Example for startup
	# Add items to the inventory (For testing, add a sword and a spear)
	#var sword_scene = load("res://weapons/Sword.tscn")

func perform_chop_action():
	skill_component.use_skill("chopping", 2.0)  # Gain XP
	var power = skill_component.get_chopping_power()
	print("You chopped with power:", power)
	# → Use this power to reduce tree HP, faster animation, etc.

func perform_mining_action():
	skill_component.use_skill("mining", 2.0)
	var power = skill_component.get_mining_power()
	print("You mined with power:", power)
	# → Use power for mining speed or yield)
	
func perform_attack():
	skill_component.use_skill("attack", 1.5)
	var damage = skill_component.get_attack_damage()
	print("You attacked with damage:", damage)
	# → Apply this damage to enemiesage)
	
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
	# Equip the weapon from the inventory

	var weapon_scene = load("res://Scenes/Weapon.tscn")
	current_weapon = weapon_scene.instantiate()
	$WeaponHolder.add_child(current_weapon)
	
	# Ensure the weapon has the attack method
	if current_weapon.has_method("attack"):
		print("Weapon equipped: %s" % weapon_name)
	else:
		print("Warning: No 'attack' method in weapon %s" % weapon_name)

	
	
func _unhandled_input(event):
	#if event.is_action_pressed("attack") and current_weapon:
		#if current_weapon.has_method("attack"):
			#current_weapon.attack()
			#
	#if event.is_action_pressed("chop_action"):
		#perform_chop_action()
	#if event.is_action_pressed("mine_action"):
		#perform_mining_action()
	#if event.is_action_pressed("attack_action"):
		#perform_attack()
		
	if event.is_action_pressed("mine_action"):
		print("Mine action triggered!")
		var overlapping = mine_detector.get_overlapping_bodies()
		print("Detected bodies: ", overlapping.size())
		for body in overlapping:
			if body.has_method("mine"):
				var mine_power = skill_component.get_mining_power()
				print("Mining with power: ", mine_power)
				body.mine(mine_power)
				skill_component.use_skill("mining", 1.0)



func _physics_process(delta):
	# Get input
	input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down").normalized()
	
	# Apply movement
	if input_direction != Vector2.ZERO:
		velocity = velocity.lerp(input_direction * speed, acceleration * delta)
	else:
		velocity = velocity.lerp(Vector2.ZERO, friction * delta)
	
	move_and_slide()
