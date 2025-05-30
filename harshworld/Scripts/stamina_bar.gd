extends ProgressBar

@onready var timer = $Timer
@onready var delay_bar = $DelayBar  # The delayed visual bar

var stamina := 0.0 : set = _set_stamina

func _set_stamina(new_stamina):
	stamina = clamp(new_stamina, 0, max_value)
	value = stamina
	if stamina <= 0:
		timer.stop()
		delay_bar.value = 0
	else:
		timer.start()

func init_stamina(_stamina):
	max_value = _stamina
	value = _stamina
	delay_bar.max_value = _stamina
	delay_bar.value = _stamina
	stamina = _stamina

func update_stamina(new_stamina):
	stamina = new_stamina  # Triggers setter

func _on_timer_timeout():
	delay_bar.value = stamina  # Smooth delay effect
