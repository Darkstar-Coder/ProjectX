# res://Scripts/rock.gd
extends Node2D

@export var max_health: float = 10.0
var current_health: float = max_health

func mine(damage: float) -> void:
	current_health -= damage
	print("rock health: ", current_health)
	
	if current_health <= 0:
		queue_free()  # Remove rock when mined down
