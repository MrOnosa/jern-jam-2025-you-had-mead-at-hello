class_name TitleScreen
extends Node2D

@onready var new_game_button: TextureButton = %NewGameButton
@onready var options_button: TextureButton = %OptionsButton
@onready var credits_button: TextureButton = %CreditsButton
@onready var bees: Node2D = %Bees
@onready var bee_flying: Sprite2D = %BeeFlying
@onready var flowers: Node2D = %Flowers
@onready var jern_jam_logo: TextureButton = %JernJamLogo



func _ready() -> void:
	AudioManager.play_title_bgm()
	
	new_game_button.pressed.connect(_on_new_game_button_pressed)
	credits_button.pressed.connect(_on_credits_button_pressed)
	options_button.pressed.connect(_on_options_button_pressed)
	
	new_game_button.mouse_entered.connect(AudioManager.button_hover)
	options_button.mouse_entered.connect(AudioManager.button_hover)
	credits_button.mouse_entered.connect(AudioManager.button_hover)
	
	animate_bee()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("open_debug_screen"):
		get_tree().change_scene_to_file("res://scenes/debug/debug_screen.tscn")
	
	
func _on_new_game_button_pressed() -> void:
	AudioManager.button_click()
	get_tree().change_scene_to_file("res://scenes/bloomheart_woods/bloomheart_woods.tscn")


func animate_bee() -> void:
	var t_bee = create_tween().set_trans(Tween.TRANS_CUBIC).set_loops(0)
	t_bee.tween_property(bee_flying,"position:y",bee_flying.position.y + 5, randi_range(2,5))
	t_bee.tween_property(bee_flying,"position:y",bee_flying.position.y - 5, randi_range(3,6))


func _on_jern_jam_logo_pressed() -> void:
	if OS.has_feature('web'):
		JavaScriptBridge.eval("window.open('https://itch.io/jam/jern-jam-2025', '_blank').focus();")
	else:
		OS.shell_open("https://itch.io/jam/jern-jam-2025")


func _on_jern_jam_logo_mouse_entered() -> void:
	var t_logo = create_tween().set_trans(Tween.TRANS_LINEAR)
	t_logo.tween_property(jern_jam_logo, "scale", Vector2(1.05,1.05),0.5)


func _on_jern_jam_logo_mouse_exited() -> void:
	var t_logo = create_tween().set_trans(Tween.TRANS_LINEAR)
	t_logo.tween_property(jern_jam_logo, "scale", Vector2.ONE,0.5)


func _on_credits_button_pressed() -> void:
	AudioManager.button_click()
	get_tree().change_scene_to_file("res://scenes/credits_scene/credits_scene.tscn")


func _on_options_button_pressed() -> void:
	AudioManager.button_click()
	get_tree().change_scene_to_file("res://scenes/options_scene/options_scene.tscn")
