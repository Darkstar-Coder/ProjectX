extends Control

# Preload your game scene
@onready var start_button = $VBoxContainer/Start_Game
@onready var options_button = $VBoxContainer/Options
@onready var quit_button = $VBoxContainer/Quit

func _ready():
	start_button.pressed.connect(_on_start_pressed)
	options_button.pressed.connect(_on_options_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _on_start_pressed():
	get_tree().change_scene_to_file("res://main.tscn")  # Replace with your actual game scene path

func _on_options_pressed():
	print("Options menu pressed.")  # You can add a real options screen here later

func _on_quit_pressed():
	get_tree().quit()
