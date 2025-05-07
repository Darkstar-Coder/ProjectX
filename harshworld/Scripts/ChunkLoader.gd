extends Node

const CHUNK_SIZE = 1024
const LOAD_DISTANCE = 2
const COLLISION_THRESHOLD = 0.1 # Alpha threshold for collisions

var loaded_chunks = {}
var player: CharacterBody2D

func _ready():
	# Wait one frame to ensure all nodes are ready
	await get_tree().process_frame
	player = get_parent().get_node("Player")
	
	if player:
		update_chunks(player.global_position)
	else:
		push_error("Player node not found!")

func update_chunks(player_pos: Vector2):
	if !is_instance_valid(player): # Safety check
		return
	
	var current_chunk = Vector2(
		floor(player_pos.x / CHUNK_SIZE),
		floor(player_pos.y / CHUNK_SIZE)
	)
	
	# Unload distant chunks
	for chunk_pos in loaded_chunks.keys():
		if abs(chunk_pos.x - current_chunk.x) > LOAD_DISTANCE or \
		   abs(chunk_pos.y - current_chunk.y) > LOAD_DISTANCE:
			_unload_chunk(chunk_pos)
	
	# Load nearby chunks
	for x in range(current_chunk.x - LOAD_DISTANCE, current_chunk.x + LOAD_DISTANCE + 1):
		for y in range(current_chunk.y - LOAD_DISTANCE, current_chunk.y + LOAD_DISTANCE + 1):
			var chunk_pos = Vector2(x, y)
			if not loaded_chunks.has(chunk_pos):
				_load_chunk(chunk_pos)

func _load_chunk(chunk_pos: Vector2):
	var chunk = preload("res://scenes/Chunk.tscn").instantiate()
	chunk.position = chunk_pos * CHUNK_SIZE
	chunk.name = "Chunk_%d_%d" % [chunk_pos.x, chunk_pos.y]
	chunk.z_index = -1 # Ensure chunks render behind player
	
	# Texture loading with validation
	var texture_path = "res://assets/chunks/chunk_%d_%d.png" % [chunk_pos.x, chunk_pos.y]
	
	if ResourceLoader.exists(texture_path):
		var texture = load(texture_path)
		var sprite = chunk.get_node("Sprite2D")
		sprite.texture = texture
		
		# Godot 4 texture repeat setting
		if texture is ImageTexture:
			texture.set_flags(0) # Disables all flags including repeat
			
		if texture.get_size() != Vector2(CHUNK_SIZE, CHUNK_SIZE):
			push_warning("Chunk texture size mismatch at %s" % texture_path)
		
		_generate_collision(chunk)
	else:
		push_warning("Missing chunk texture: %s" % texture_path)
	
	add_child(chunk)
	loaded_chunks[chunk_pos] = chunk

func _unload_chunk(chunk_pos: Vector2):
	if loaded_chunks.has(chunk_pos):
		loaded_chunks[chunk_pos].queue_free()
		loaded_chunks.erase(chunk_pos)

func _generate_collision(chunk: Node2D):
	var static_body = chunk.get_node("StaticBody2D")
	
	# Clear existing collisions
	for child in static_body.get_children():
		child.queue_free()
	
	var texture = chunk.get_node("Sprite2D").texture
	if !texture:
		return
		
	var image = texture.get_image()
	if image.is_compressed():
		image.decompress()
	
	var bitmap = BitMap.new()
	bitmap.create_from_image_alpha(image)
	
	var polygons = bitmap.opaque_to_polygons(
		Rect2(0, 0, CHUNK_SIZE, CHUNK_SIZE), 
		COLLISION_THRESHOLD
	)
	
	for polygon in polygons:
		var collision = CollisionPolygon2D.new()
		collision.polygon = polygon
		static_body.add_child(collision)
