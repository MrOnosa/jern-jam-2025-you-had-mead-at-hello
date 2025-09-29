class_name CreditsScene
extends Control

@onready var credits_content: RichTextLabel = %CreditsContent
@onready var title_button: TextureButton = %TitleButton
@onready var bee: Sprite2D = %Bee
@onready var bee_2: Sprite2D = %Bee2


func _ready() -> void:
	title_button.pressed.connect(_on_title_button_pressed)
	credits_content.meta_clicked.connect(_on_credits_meta_clicked)
	
	title_button.mouse_entered.connect(AudioManager.button_hover)
	
	animate_bees()
	
	
func _on_title_button_pressed() -> void:
	AudioManager.button_click()
	get_tree().change_scene_to_file("res://scenes/title_screen/title_screen.tscn")


func _on_credits_meta_clicked(meta) -> void:
	OS.shell_open(str(meta))


func animate_bees() -> void:
	var t_bee = create_tween().set_trans(Tween.TRANS_CUBIC).set_loops(0)
	t_bee.tween_property(bee,"position:y",bee.position.y + 10, randi_range(2,5))
	t_bee.tween_property(bee,"position:y",bee.position.y - 10, randi_range(3,6))
	
	var t_bee2 = create_tween().set_trans(Tween.TRANS_CUBIC).set_loops(0)
	t_bee2.tween_property(bee_2,"position:y",bee_2.position.y + 15, randi_range(2,6))
	t_bee2.tween_property(bee_2,"position:y",bee_2.position.y - 15, randi_range(3,8))
