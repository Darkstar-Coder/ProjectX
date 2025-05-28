extends Node2D

@export var max_health: float = 10.0
var current_health: float

@onready var healthbar = $HealthBar

func _ready():
	current_health = max_health
	healthbar.init_health(current_health)

func mine(damage: float):
	current_health -= damage
	current_health = max(current_health, 0.0)

	update_health_display()

	if current_health <= 0:
		die()

func update_health_display():
	if healthbar:
		healthbar.update_health(current_health)

func die():
	print("💥 Rock destroyed!")
	queue_free()
