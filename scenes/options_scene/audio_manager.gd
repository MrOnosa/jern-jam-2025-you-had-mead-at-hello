extends Node

signal song_changed(title: String, artist: String)

# Music Playlist
var title_song: AudioStream = preload("uid://clpl30ka3t87u")
var game_loop: AudioStream = preload("uid://cflk6iew1atom")

var ost_playlist: Dictionary = {
	"title": {
		"song": title_song,
		"name": "Morning Drizzle",
		"artist": "Ategondev"
	},
	"game_loop": {
		"song": game_loop,
		"name": "Sunny Beesness",
		"artist": "Ategondev"
	}
}

var bgm_player: AudioStreamPlayer

# Sound Effects Variables
var button_hover_sfx: AudioStream = preload("uid://eftifp5h88l0")
var button_click_sfx: AudioStream = preload("uid://bkwul40wn181j")
var extractor_sfx: AudioStream = preload("uid://c3kda4m4vp38j")
var walking_ground_sfx: AudioStream = preload("uid://cflj256yp5p1b")


func _ready() -> void:
	bgm_player = AudioStreamPlayer.new()
	add_child(bgm_player)
	bgm_player.bus = "Music"


func play_sound(audio_file: AudioStream, _distance: float = 0.0, _position: Vector2 = Vector2(0,0), _vary: bool = false) -> void:
	var audio_player
	
	if _distance > 0.0:
		print(_distance)
		audio_player = AudioStreamPlayer2D.new()
		audio_player.max_distance = _distance
		audio_player.position = _position
	else:
		audio_player = AudioStreamPlayer.new()
	
	add_child(audio_player)
	audio_player.finished.connect(audio_player.queue_free)
	audio_player.bus = "SFX"
	audio_player.stream = audio_file
	
	if _vary:
		audio_player.pitch_scale = randf_range(0.8,1.2)
	
	audio_player.play()


func button_hover() -> void:
	play_sound(button_hover_sfx)
	

func button_click() -> void:
	play_sound(button_click_sfx)
	
	
func play_extractor_sound(_position: Vector2) -> void:
	play_sound(extractor_sfx, 600.0, _position)
	
	
func play_walking_sound() -> void:
	play_sound(walking_ground_sfx, 0.0, Vector2.ZERO, true)


func play_bgm(audio_file: AudioStream) -> void:
	bgm_player.stream = audio_file
	bgm_player.play()
	
	
func stop_bgm() -> void:
	bgm_player.stop()


func play_title_bgm() -> void:
	play_bgm(ost_playlist["title"].song)
	song_changed.emit(ost_playlist["title"].name,ost_playlist["title"].artist)


func play_game_bgm() -> void:
	play_bgm(ost_playlist["game_loop"].song)
	song_changed.emit(ost_playlist["game_loop"].name,ost_playlist["game_loop"].artist)
