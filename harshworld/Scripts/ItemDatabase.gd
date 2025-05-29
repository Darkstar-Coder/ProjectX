extends Node

var items = {
	"rock_shard": {
		"name": "Rock Shard",
		"texture": preload("res://Assets/objects/Gem2.png")
	}
}

func get_item(id: String) -> Dictionary:
	return items.get(id, {})
