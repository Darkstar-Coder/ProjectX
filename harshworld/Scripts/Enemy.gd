extends CharacterBody2D

@export var speed: float = 50.0
@export var detection_radius: float = 300.0
@export var attack_range: float = 50.0
@onready var healthbar = $HealthBar
var player: Node2D = null
var health: int = 100

func _ready():
	# Add a collision shape (make sure to add a CollisionShape2D node to your enemy)
	$CollisionShape2D.shape = CircleShape2D.new()
	$CollisionShape2D.shape.radius = 20
	
	# Add detection area (make sure to add an Area2D node with a CollisionShape2D child)
	$DetectionArea/CollisionShape2D.shape = CircleShape2D.new()
	$DetectionArea/CollisionShape2D.shape.radius = detection_radius
	
	# Connect signals
	$DetectionArea.body_entered.connect(_on_body_entered)
	$DetectionArea.body_exited.connect(_on_body_exited)
	
	healthbar.init_health(health)

func _physics_process(delta):
	if player:
		var direction = (player.global_position - global_position).normalized()
		
		# Move towards player
		velocity = direction * speed
		
		# If we're close enough to attack
		if global_position.distance_to(player.global_position) < attack_range:
			velocity = Vector2.ZERO  # Stop moving when in attack range
			#attack()
		
		move_and_slide()

#func attack():
	# Implement your attack logic here
	# For example, deal damage to player or play attack animation
	#print("")
	# You might want to add a cooldown timer for attacks

func take_damage(amount: int):
	health -= amount
	print("Enemy Took damage")
	update_health_display()
	if health <= 0:
		die()

func die():
	# Implement death behavior (play animation, drop items, etc.)
	queue_free()
	
func update_health_display():
	if healthbar:
		healthbar.update_health(health)

func _on_body_entered(body: Node2D):
	if body.is_in_group("player"):
		player = body

func _on_body_exited(body: Node2D):
	if body == player:
		player = null
		velocity = Vector2.ZERO
