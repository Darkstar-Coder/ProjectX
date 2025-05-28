extends CharacterBody2D

@onready var stat_component = $StatComponent
@onready var skill_component = $SkillComponent
@onready var mine_detector = $MineDetector
@onready var animated_sprite = $AnimatedSprite2D  # Add this line

@export var speed: float = 150.0
@export var acceleration: float = 15.0
@export var friction: float = 10.0

# Combat & Skill Parameters
@export var weapon_radius: float = 32.0
@export var chopping_xp_gain: float = 2.0
@export var mining_xp_gain: float = 2.0
@export var attack_xp_gain: float = 1.5

var input_direction: Vector2 = Vector2.ZERO
var current_weapon: Node = null

func _ready():
	z_index = 10  # Ensure player renders above background
	#equip_weapon("Sword")  # Optional: start with a weapon

func perform_chop_action():
	skill_component.use_skill("chopping", chopping_xp_gain)
	var power = skill_component.get_chopping_power()
	print("You chopped with power:", power)

func perform_mining_action():
	skill_component.use_skill("mining", mining_xp_gain)
	var power = skill_component.get_mining_power()
	print("You mined with power:", power)

func perform_attack():
	skill_component.use_skill("attack", attack_xp_gain)
	var damage = skill_component.get_attack_damage()
	print("You attacked with damage:", damage)

func _process(_delta):
	var mouse_global = get_global_mouse_position()
	var to_mouse = mouse_global - global_position
	var clamped_position = to_mouse.limit_length(weapon_radius)
	$WeaponHolder.position = clamped_position
	$WeaponHolder.rotation = to_mouse.angle()

func equip_weapon(weapon_name: String):
	var weapon_scene = load("res://Scenes/Weapon.tscn")
	current_weapon = weapon_scene.instantiate()
	$WeaponHolder.add_child(current_weapon)

	if current_weapon.has_method("attack"):
		print("Weapon equipped: %s" % weapon_name)
	else:
		print("Warning: No 'attack' method in weapon %s" % weapon_name)

func _unhandled_input(event):
	if event.is_action_pressed("mine_action"):
		print("Mine action triggered!")
		var overlapping = mine_detector.get_overlapping_bodies()
		print("Detected bodies: ", overlapping.size())
		for body in overlapping:
			if body.has_method("mine"):
				var mine_power = skill_component.get_mining_power()
				print("Mining with power: ", mine_power)
				body.mine(mine_power)
				skill_component.use_skill("mining", mining_xp_gain)

func _physics_process(delta):
	input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down").normalized()

	if input_direction != Vector2.ZERO:
		velocity = velocity.lerp(input_direction * speed, acceleration * delta)
		
		# Play Run animation
		if not animated_sprite.is_playing() or animated_sprite.animation != "Run":
			animated_sprite.play("Run")

		# Flip the sprite based on direction
		if input_direction.x < 0:
			animated_sprite.flip_h = true
		elif input_direction.x > 0:
			animated_sprite.flip_h = false
	else:
		velocity = velocity.lerp(Vector2.ZERO, friction * delta)
		animated_sprite.stop()  # Stop animation if idle

	move_and_slide()
