class_name TitleScreen
extends Node2D

@onready var new_game_button: TextureButton = %NewGameButton
@onready var options_button: TextureButton = %OptionsButton
@onready var credits_button: TextureButton = %CreditsButton
@onready var bees: Node2D = %Bees
@onready var bee_flying: Sprite2D = %BeeFlying
@onready var flowers: Node2D = %Flowers
@onready var sfx_accept: AudioStreamPlayer = %SFXAccept
@onready var sfx_hover: AudioStreamPlayer = %SFXHover


func _ready() -> void:
	new_game_button.pressed.connect(_on_new_game_button_pressed)
	
	new_game_button.mouse_entered.connect(button_hover_sound)
	options_button.mouse_entered.connect(button_hover_sound)
	credits_button.mouse_entered.connect(button_hover_sound)
	
	animate_bee()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("open_debug_screen"):
		get_tree().change_scene_to_file("res://scenes/debug/debug_screen.tscn")
	
	
func _on_new_game_button_pressed() -> void:
	button_click_sound()
	get_tree().change_scene_to_file("res://scenes/world.tscn")


func animate_bee() -> void:
	var t_bee = create_tween().set_trans(Tween.TRANS_CUBIC).set_loops(0)
	t_bee.tween_property(bee_flying,"position:y",bee_flying.position.y + 5, randi_range(2,5))
	t_bee.tween_property(bee_flying,"position:y",bee_flying.position.y - 5, randi_range(3,6))


func button_hover_sound() -> void:
	sfx_hover.pitch_scale = randf_range(0.8,1.2)
	sfx_hover.play()
	
	
func button_click_sound() -> void:
	sfx_accept.pitch_scale = randf_range(0.8,1.2)
	sfx_accept.play()
