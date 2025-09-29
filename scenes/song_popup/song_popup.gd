class_name SongPopup
extends Node2D

@onready var song_label: Label = %SongLabel
@onready var composer_label: Label = %ComposerLabel

var song_name: String = ""
var composer_name: String = ""

var ending_position: Vector2

func _ready() -> void:
	song_label.text = song_name
	composer_label.text = composer_name
	
	self_modulate.a = 0
	ending_position = position
	position = Vector2(-1280,position.y)
	
	show_song()
	
	
func show_song() -> void:
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(self, "modulate:a",1,1.0)
	tween.tween_property(self, "position",ending_position,1.0)
	
	var timer = get_tree().create_timer(5.0)
	timer.timeout.connect(hide_song)
	
	
func hide_song() -> void:
	var t_hide = create_tween().set_trans(Tween.TRANS_LINEAR)
	t_hide.tween_property(self, "modulate:a",0,1.0)
	
	var timer = get_tree().create_timer(3.0)
	timer.timeout.connect(queue_free)
