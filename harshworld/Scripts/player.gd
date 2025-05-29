extends CharacterBody2D

@onready var stat_component = $StatComponent
@onready var skill_component = $SkillComponent
@onready var mine_detector = $MineDetector
@onready var animated_sprite = $AnimatedSprite2D
@export var projectile_scene: PackedScene = load("res://Scenes/Projectile.tscn")

@export var max_health := 100

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
var current_health := max_health

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
	
func take_damage(amount: float):
	current_health -= amount
	print("Player health:", current_health)
	if current_health <= 0:
		die()
func shoot_projectile():
	if projectile_scene == null:
		print("No projectile scene assigned!")
		return

	var projectile = projectile_scene.instantiate()
	var mouse_pos = get_global_mouse_position()
	var direction = (mouse_pos - global_position).normalized()

	projectile.position = global_position
	projectile.direction = direction
	get_tree().current_scene.add_child(projectile)


func die():
	print("Player died")
	queue_free()

func _process(_delta):
	# Update weapon position and rotation visually
	var mouse_global = get_global_mouse_position()
	var to_mouse = mouse_global - global_position
	var direction = to_mouse.normalized()

	var clamped_position = direction * weapon_radius
	$WeaponHolder.position = clamped_position
	$WeaponHolder.rotation = to_mouse.angle()

func _physics_process(delta):
	# Handle player movement
	input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down").normalized()

	if input_direction != Vector2.ZERO:
		velocity = velocity.lerp(input_direction * speed, acceleration * delta)

		# Play Run animation
		if not animated_sprite.is_playing() or animated_sprite.animation != "Run":
			animated_sprite.play("Run")

		# Flip sprite based on movement direction
		if input_direction.x < 0:
			animated_sprite.flip_h = true
		elif input_direction.x > 0:
			animated_sprite.flip_h = false
	else:
		velocity = velocity.lerp(Vector2.ZERO, friction * delta)
		animated_sprite.stop()

	move_and_slide()

	# Update mine detector position so physics detects overlaps correctly
	var mouse_global = get_global_mouse_position()
	var to_mouse = mouse_global - global_position
	var direction = to_mouse.normalized()
	var detector_distance: float = 50.0  # Adjust this to move detector closer/farther from player
	mine_detector.position = direction * detector_distance

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
	if event.is_action_pressed("attack_action"):
		shoot_projectile()

	if event.is_action_pressed("attack_action"):
		print("Attack action triggered!")
		var overlapping = mine_detector.get_overlapping_bodies()
		print("Detected bodies for attack: ", overlapping.size())
		for body in overlapping:
			if body.has_method("take_damage"):
				var damage = skill_component.get_attack_damage()
				print("Attacking with damage: ", damage)
				body.take_damage(damage)
				skill_component.use_skill("attack", attack_xp_gain)
