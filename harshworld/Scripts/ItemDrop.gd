extends Node2D

@export var item_id: String
@export var quantity: int = 1

@onready var sprite: Sprite2D = $Sprite2D
var pending_item_id := ""
var pending_quantity := 1
var initialized := false

func _ready():
	if pending_item_id != "":
		init(pending_item_id, pending_quantity)
		# Connect to Area2D signal
		$Area2D.connect("body_entered", _on_body_entered)

func init(id: String, amount: int = 1):
	if not sprite:  # if _ready hasn't run yet
		pending_item_id = id
		pending_quantity = amount
		return

	item_id = id
	quantity = amount
	_apply_item_data(item_id)
	initialized = true
	
func _on_body_entered(body):
	if body.name == "Player":  # Or use group: if body.is_in_group("player")
		Inventory.add_item(item_id, quantity) # Add item to player's inventory here
		print("🧲 Player picked up:", item_id)

		

		# Optional: Play pickup animation or sound here

		queue_free()  # Remove the item


func _apply_item_data(id: String):
	var data = ItemDatabase.get_item(id)
	if data.has("texture") and sprite:
		sprite.texture = data.texture
	else:
		push_warning("ItemDrop: Missing texture or sprite node for item_id: '%s'" % id)
