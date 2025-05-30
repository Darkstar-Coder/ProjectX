extends Node

# Dictionary to store item_id → quantity
var items: Dictionary = {}

# Adds item to inventory
func add_item(item_id: String, quantity: int = 1):
	if item_id in items:
		items[item_id] += quantity
	else:
		items[item_id] = quantity

	print("📦 Picked up:", quantity, "x", item_id)
	print("🎒 Inventory now:", items)

# Get quantity of an item
func get_quantity(item_id: String) -> int:
	return items.get(item_id, 0)

# Remove item (optional)
func remove_item(item_id: String, quantity: int = 1):
	if item_id in items:
		items[item_id] -= quantity
		if items[item_id] <= 0:
			items.erase(item_id)
