extends ProgressBar

@onready var timer = $Timer
@onready var damage_bar = $DamageBar

var health := 0.0 : set = _set_health

func _set_health(new_health):
	health = clamp(new_health, 0, max_value)
	value = health  # Updates the green bar immediately

	if health <= 0:
		queue_free()
	else:
		timer.start()  # Wait before updating red damage bar

func init_health(_health):
	max_value = _health
	value = _health
	damage_bar.max_value = _health
	damage_bar.value = _health
	health = _health  # Triggers setter

func update_health(new_health):
	health = new_health  # Triggers setter

func _on_timer_timeout():
	damage_bar.value = health  # Snap damage bar after delay
