extends Node2D

@onready var title_button: TextureButton = %TitleButton

func _ready() -> void:
	title_button.pressed.connect(_on_title_button_pressed)
		
func _on_title_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/title_screen/title_screen.tscn")
