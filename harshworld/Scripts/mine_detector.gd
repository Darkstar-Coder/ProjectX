extends Area2D

@onready var collision_shape := $CollisionShape2D

func _draw():
	if collision_shape.shape is RectangleShape2D:
		var rect_size = collision_shape.shape.extents * 2.0
		var rect_position = -collision_shape.shape.extents
		draw_rect(Rect2(rect_position, rect_size), Color(0, 1, 0, 0.4))  # Green transparent

func _process(_delta):
	queue_redraw()
