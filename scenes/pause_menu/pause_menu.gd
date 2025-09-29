class_name PauseMenu
extends Control

@onready var primary_volume: HSlider = %PrimaryVolume
@onready var music_volume: HSlider = %MusicVolume
@onready var sfx_volume: HSlider = %SFXVolume
@onready var sandbox_check: CheckBox = %SandboxCheck
@onready var title_button: TextureButton = %TitleButton
@onready var primary_value_label: Label = %PrimaryValueLabel
@onready var music_value_label: Label = %MusicValueLabel
@onready var sfx_value_label: Label = %SFXValueLabel
@onready var quit_button: TextureButton = %QuitButton


var primary_value: float
var music_value: float
var sfx_value: float

var showed_warning: bool = false


func _ready() -> void:
	primary_volume.value_changed.connect(set_primary_level)
	music_volume.value_changed.connect(set_music_level)
	sfx_volume.value_changed.connect(set_sfx_level)
	
	title_button.pressed.connect(hide_pause_menu)
	title_button.mouse_entered.connect(AudioManager.button_hover)
	quit_button.pressed.connect(_on_quit_button_pressed)
	quit_button.mouse_entered.connect(AudioManager.button_hover)
	sandbox_check.pressed.connect(_on_sandbox_checked)
	
	sandbox_check.button_pressed = Utility.sandbox_enabled
	
	get_audio_levels()


func get_audio_levels() -> void:
	primary_value = db_to_linear(AudioServer.get_bus_volume_db(0))
	music_value = db_to_linear(AudioServer.get_bus_volume_db(1))
	sfx_value = db_to_linear(AudioServer.get_bus_volume_db(2))
	
	primary_volume.value = primary_value
	music_volume.value = music_value
	sfx_volume.value = sfx_value
	
	update_labels()


func update_labels() -> void:
	primary_value_label.text = str(snappedf(primary_volume.value,0.05))
	music_value_label.text = str(snappedf(music_volume.value,0.05))
	sfx_value_label.text = str(snappedf(sfx_volume.value,0.05))


func set_primary_level(new_value: float) -> void:
	AudioServer.set_bus_volume_db(0,linear_to_db(new_value))
	update_labels()
	
	
func set_music_level(new_value: float) -> void:
	Utility.music_is_muted = new_value == 0.0
	AudioServer.set_bus_volume_db(1,linear_to_db(new_value))
	update_labels()
	
	
func set_sfx_level(new_value: float) -> void:
	AudioServer.set_bus_volume_db(2,linear_to_db(new_value))
	update_labels()
	

func hide_pause_menu() -> void:
	$QuitButton/Label.text = "To Title"
	showed_warning = false
	AudioManager.button_click()
	hide()


func _on_sandbox_checked() -> void:
	AudioManager.button_click()
	Utility.sandbox_enabled = !Utility.sandbox_enabled


func _on_quit_button_pressed() -> void:
	if showed_warning:
		get_tree().change_scene_to_file("res://scenes/title_screen/title_screen.tscn")
	else:
		$ToTitleWarningTimer.start()
		$QuitButton/Label.text = "You sure?\nProgress will be lost!"


func _on_to_title_warning_timer_timeout() -> void:	
	showed_warning = true
