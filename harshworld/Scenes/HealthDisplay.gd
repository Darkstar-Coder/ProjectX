# HealthDisplay.gd
extends Control

@onready var health_label = $PanelContainer/HealthLabel
var hide_timer := Timer.new()

func _ready():
	add_child(hide_timer)
	hide_timer.wait_time = 3.0
	hide_timer.one_shot = true
	hide_timer.connect("timeout", Callable(self, "_on_hide_timer_timeout"))
	hide()

func show_health(value: float):
	health_label.text = str(value)
	show()
	hide_timer.start()

func _on_hide_timer_timeout():
	hide()
