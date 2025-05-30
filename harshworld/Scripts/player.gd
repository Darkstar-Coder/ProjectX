extends CharacterBody2D

@onready var stat_component = $StatComponent
@onready var skill_component = $SkillComponent
@onready var mine_detector = $MineDetector
@onready var animated_sprite = $AnimatedSprite2D
@onready var stamina_bar = $StaminaBar  # Adjust path
@export var max_stamina: float = 100.0
@export var stamina_regen_rate: float = 10.0  # Per second
@export var mining_stamina_cost: float = 15.0
@export var attack_stamina_cost: float = 10.0

var current_stamina: float = max_stamina
@export var projectile_scene: PackedScene = load("res://Scenes/Projectile.tscn")

@export var max_health := 100
@export var stamina_recovery_rate := 10.0  # Stamina per second

@export var mine_stamina_cost := 15.0

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
	current_stamina = max_stamina
	stamina_bar.init_stamina(max_stamina)


func perform_chop_action():
	if current_stamina >= mine_stamina_cost:
		skill_component.use_skill("chopping", chopping_xp_gain)
		var power = skill_component.get_chopping_power()
		current_stamina -= mine_stamina_cost
		print("You chopped with power:", power)
	else:
		print("Not enough stamina to chop")

func perform_mining_action():
	if current_stamina >= mine_stamina_cost:
		skill_component.use_skill("mining", mining_xp_gain)
		var power = skill_component.get_mining_power()
		current_stamina -= mine_stamina_cost
		print("You mined with power:", power)
	else:
		print("Not enough stamina to mine")

func perform_attack():
	if current_stamina >= attack_stamina_cost:
		skill_component.use_skill("attack", attack_xp_gain)
		var damage = skill_component.get_attack_damage()
		current_stamina -= attack_stamina_cost
		print("You attacked with damage:", damage)
	else:
		print("Not enough stamina to attack")

func take_damage(amount: float):
	current_health -= amount
	print("Player health:", current_health)
	if current_health <= 0:
		die()
		
func use_stamina(amount: float) -> bool:
	if current_stamina >= amount:
		current_stamina -= amount
		stamina_bar.update_stamina(current_stamina)
		return true
	else:
		print("❌ Not enough stamina!")
		return false


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

func _process(delta):
	# Stamina regen
	if current_stamina < max_stamina:
		current_stamina += stamina_regen_rate * delta
		current_stamina = min(current_stamina, max_stamina)
		stamina_bar.update_stamina(current_stamina)

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

		if not animated_sprite.is_playing() or animated_sprite.animation != "Run":
			animated_sprite.play("Run")

		if input_direction.x < 0:
			animated_sprite.flip_h = true
		elif input_direction.x > 0:
			animated_sprite.flip_h = false
	else:
		velocity = velocity.lerp(Vector2.ZERO, friction * delta)
		animated_sprite.stop()

	move_and_slide()

	var mouse_global = get_global_mouse_position()
	var to_mouse = mouse_global - global_position
	var direction = to_mouse.normalized()
	var detector_distance: float = 50.0
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
		if use_stamina(mining_stamina_cost):
			var overlapping = mine_detector.get_overlapping_bodies()
			for body in overlapping:
				if body.has_method("mine"):
					var mine_power = skill_component.get_mining_power()
					body.mine(mine_power)
					skill_component.use_skill("mining", mining_xp_gain)

	if event.is_action_pressed("attack_action"):
		if use_stamina(attack_stamina_cost):
			shoot_projectile()
			var overlapping = mine_detector.get_overlapping_bodies()
			for body in overlapping:
				if body.has_method("take_damage"):
					var damage = skill_component.get_attack_damage()
					body.take_damage(damage)
					skill_component.use_skill("attack", attack_xp_gain)
