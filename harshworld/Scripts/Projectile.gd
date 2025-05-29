extends Area2D

@export var speed := 300.0
var damage := 1.0
var direction := Vector2.RIGHT

func initialize(damage_value: float, rotation_angle: float):
	damage = damage_value
	rotation = rotation_angle
	direction = Vector2.RIGHT.rotated(rotation)

func _ready():
	body_entered.connect(_on_body_entered)


func _physics_process(delta):
	position += direction * speed * delta

func _on_body_entered(body):
	if body.is_in_group("Enemies") and body.has_method("take_damage"):
		body.take_damage(damage)
		queue_free()
