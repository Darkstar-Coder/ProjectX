extends Node2D

var is_attacking = false

func _ready():
	$Sprite.animation_finished.connect(_on_Sprite_animation_finished)

func attack():
	# Prevent attacking again while the previous animation is still playing
	if is_attacking:
		return
	
	is_attacking = true
	$Sprite.play("attack")  # Start the attack animation

func _on_Sprite_animation_finished():
	# Reset attack status once the attack animation is done
	if $Sprite.animation == "attack":
		is_attacking = false  # Allow attacking again
