class_name CreditsScene
extends Control

@onready var credits_content: RichTextLabel = %CreditsContent
@onready var title_button: TextureButton = %TitleButton
@onready var sfx_accept: AudioStreamPlayer = %SFXAccept
@onready var sfx_hover: AudioStreamPlayer = %SFXHover
@onready var bee: Sprite2D = %Bee
@onready var bee_2: Sprite2D = %Bee2


func _ready() -> void:
	title_button.pressed.connect(_on_title_button_pressed)
	credits_content.meta_clicked.connect(_on_credits_meta_clicked)
	
	title_button.mouse_entered.connect(button_hover_sound)
	
	animate_bees()
	
	
func _on_title_button_pressed() -> void:
	button_click_sound()
	get_tree().change_scene_to_file("res://scenes/title_screen/title_screen.tscn")


func _on_credits_meta_clicked(meta) -> void:
	OS.shell_open(str(meta))


func button_hover_sound() -> void:
	sfx_hover.pitch_scale = randf_range(0.8,1.2)
	sfx_hover.play()
	
	
func button_click_sound() -> void:
	sfx_accept.pitch_scale = randf_range(0.8,1.2)
	sfx_accept.play()

func animate_bees() -> void:
	var t_bee = create_tween().set_trans(Tween.TRANS_CUBIC).set_loops(0)
	t_bee.tween_property(bee,"position:y",bee.position.y + 10, randi_range(2,5))
	t_bee.tween_property(bee,"position:y",bee.position.y - 10, randi_range(3,6))
	
	var t_bee2 = create_tween().set_trans(Tween.TRANS_CUBIC).set_loops(0)
	t_bee2.tween_property(bee_2,"position:y",bee_2.position.y + 15, randi_range(2,6))
	t_bee2.tween_property(bee_2,"position:y",bee_2.position.y - 15, randi_range(3,8))
