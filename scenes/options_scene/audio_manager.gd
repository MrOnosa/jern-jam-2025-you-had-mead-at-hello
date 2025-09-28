extends Node

signal song_changed(title: String, artist: String)

# Music Playlist
var ost_playlist: Dictionary = {
	"title": {
		"song": "", # preload() here
		"name": "Title Music",
		"artist": "Ategon"
	}
}

var bgm_player: AudioStreamPlayer

# Sound Effects Variables
var button_hover_sfx: AudioStream = preload("res://assets/sfx/ui_hover.ogg")
var button_click_sfx: AudioStream = preload("res://assets/sfx/ui_accept.ogg")


func _read() -> void:
	bgm_player = AudioStreamPlayer.new()
	add_child(bgm_player)
	bgm_player.bus = "Music"


func play_sound(audio_file: AudioStream) -> void:
	var audio_player: AudioStreamPlayer = AudioStreamPlayer.new()
	add_child(audio_player)
	audio_player.finished.connect(audio_player.queue_free)
	audio_player.bus = "SFX"
	audio_player.stream = audio_file
	audio_player.play()


func button_hover() -> void:
	play_sound(button_hover_sfx)
	

func button_click() -> void:
	play_sound(button_click_sfx)


func play_bgm(audio_file: AudioStream) -> void:
	bgm_player.stream = audio_file
	bgm_player.play()
	
	
func stop_bgm() -> void:
	bgm_player.stop()
