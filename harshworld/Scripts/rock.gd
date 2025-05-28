extends Node2D

@export var max_health: float = 10.0
var current_health: float

@onready var health_display = $HealthDisplay  # Adjust this path if needed

func _ready():
	current_health = max_health
	update_health_display()

func mine(damage: float):
	current_health -= damage
	current_health = max(current_health, 0.0)  # Prevent negative HP

	update_health_display()

	if current_health <= 0:
		die()

func update_health_display():
	if health_display:
		health_display.show_health(current_health)

func die():
	print("💥 Rock destroyed!")
	queue_free()
