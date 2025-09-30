class_name SongPopup
extends Node2D

@onready var song_label: Label = %SongLabel
@onready var composer_label: Label = %ComposerLabel
@onready var music_muted_label: Label = %MusicMutedLabel

var song_name: String = ""
var composer_name: String = ""

var starting_position: Vector2
var ending_position: Vector2

func _ready() -> void:
	song_label.text = song_name
	composer_label.text = composer_name
	music_muted_label.visible = Utility.music_is_muted		
	
	self_modulate.a = 0
	ending_position = position
	position = Vector2(-1280,position.y)
	starting_position = position
	
	show_song()
	
func show_song() -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "position",ending_position,2.0)
	
	var tween2 = create_tween()
	tween2.tween_property(self, "modulate:a",1,0.5).set_delay(1.5)
	
	var timer = get_tree().create_timer(10.0)
	timer.timeout.connect(hide_song)
	
	
func hide_song() -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "position",starting_position,1.0)
	
	var tween2 = create_tween()
	tween2.tween_property(self, "modulate:a",0,0.3)
	
	var timer = get_tree().create_timer(3.0)
	timer.timeout.connect(queue_free)
