extends Node2D

@export var max_health: float = 10.0
@export var item_drop_scene: PackedScene = preload("res://Scenes/ItemDrop.tscn")
@export var item_drop_id: String = "rock_shard"
@export var item_drop_quantity: int = 1

var current_health: float

@onready var healthbar = $HealthBar

func _ready():
	current_health = max_health
	if healthbar:
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

	# ✅ Safe and clean item drop logic
	if item_drop_scene and item_drop_id != "":
		var drop = item_drop_scene.instantiate()

		if drop.has_method("init"):
			drop.init(item_drop_id, item_drop_quantity)  # cleaner than manually setting vars

		get_tree().current_scene.add_child(drop)
		drop.global_position = global_position
		print("✅ Item dropped at:", drop.global_position)
	else:
		push_warning("Item drop failed: missing scene or item_id.")

	queue_free()
