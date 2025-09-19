class_name TitleScreen
extends Node2D

@onready var new_game_button: TextureButton = %NewGameButton
@onready var options_button: TextureButton = %OptionsButton
@onready var exit_button: TextureButton = %ExitButton

func _ready() -> void:
	new_game_button.pressed.connect(_on_new_game_button_pressed)
	
	
func _on_new_game_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/world.tscn")
