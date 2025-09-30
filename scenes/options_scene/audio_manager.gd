extends Node

signal song_changed(title: String, artist: String)

# Music Playlist
const _1_MORNING_DRIZZLE: AudioStream = preload("uid://jeaahqyf2oer")
const _2_SUNNY_BEESNESS: AudioStream = preload("uid://7eu2wgatxulq")
const _3_BUZZY_MEADOWS: AudioStream = preload("uid://dkajangi3oyuf")
const _4_HYMNOPTERA: AudioStream = preload("uid://dp6yxq8c7syqy")
const _5_APIARY_NIGHTCLUB: AudioStream = preload("uid://xr4y4mcafidq")
const _6_WAGGLE_DANCE: AudioStream = preload("uid://re0xhrahx386")
const _7_MURDER_HORNET: AudioStream = preload("uid://cg82ymi06f3wf")
const _8_NUC_NUKE: AudioStream = preload("uid://cffh7se8h242e")


var ost_playlist: Dictionary = {
	"1": {
		"song": _1_MORNING_DRIZZLE,
		"name": "Morning Drizzle",
		"artist": "Ategon",
		"unlocked": true,
		"volume": -10.0
	},
	"2": {
		"song": _2_SUNNY_BEESNESS,
		"name": "Sunny Beesness",
		"artist": "Ategon",
		"unlocked": true,
		"volume": -10.0
	},
	"3": {
		"song": _3_BUZZY_MEADOWS,
		"name": "Buzzy Meadows",
		"artist": "Ategon",
		"unlocked": true,
		"volume": -10.0
	},
	"4": {
		"song": _4_HYMNOPTERA,
		"name": "Hymnoptera",
		"artist": "Ategon",
		"unlocked": true,
		"volume": -10.0
	},
	"5": {
		"song": _5_APIARY_NIGHTCLUB,
		"name": "Apiary Nightclub",
		"artist": "Ategon",
		"unlocked": true,
		"volume": -10.0
	},
	"6": {
		"song": _6_WAGGLE_DANCE,
		"name": "Waggle Dance",
		"artist": "Ategon",
		"unlocked": true,
		"volume": -10.0
	},
	"7": {
		"song": _7_MURDER_HORNET,
		"name": "Murder Hornet",
		"artist": "Ategon",
		"unlocked": false,
		"volume": -10.0
	},
	"8": {
		"song": _8_NUC_NUKE,
		"name": "Nuc Nuke",
		"artist": "Ategon",
		"unlocked": false,
		"volume": -10.0
	}
}

var current_song_index: int = 1
var is_playlist_active: bool = false
var bgm_player: AudioStreamPlayer
var volume_tween: Tween

# Sound Effects Variables
const button_hover_sfx: AudioStream = preload("uid://eftifp5h88l0")
const button_click_sfx: AudioStream = preload("uid://bkwul40wn181j")
const extractor_sfx: AudioStream = preload("uid://c3kda4m4vp38j")
const walking_ground_sfx: AudioStream = preload("uid://cflj256yp5p1b")
const SFX_BEE_BUZZING_LOW: AudioStream = preload("uid://c5yocx0h6shgx")
const SFX_DROP_HONEY_BUCKET: AudioStream = preload("uid://blrxdg87hlpax")
const SFX_MEAD_MAKING: AudioStream = preload("uid://c16twfc54ea4j")
const SFX_MONEY_GAIN: AudioStream = preload("uid://ci558vfm1cgky")
const SFX_PACKAGE_MEAD: AudioStream = preload("uid://21t11ijgqcw")
const SFX_PICKUP_SOUND: AudioStream = preload("uid://cmfh704imcqnl")
const SFX_WALKING_BUSHES: AudioStream = preload("uid://c0lk4t3c8runo")
const ERROR_SOUND = preload("uid://bysjwgwokw1ve")
const BEAR_STATUE_GOLDEN = preload("uid://dome0qtpvisdv")
const BEAR_STATUE_OFFERING = preload("uid://fdh50mldtvy7")
const BEAR_STATUE_PLACED = preload("uid://ul6dkatsgyo7")


func _ready() -> void:
	bgm_player = AudioStreamPlayer.new()
	add_child(bgm_player)
	bgm_player.bus = "Music"
	bgm_player.finished.connect(_on_song_finished)


func play_sound(audio_file: AudioStream, _vary: bool = false, _distance: float = 0.0, _position: Vector2 = Vector2(0,0), _volume: float = 0.0) -> void:
	var audio_player
	
	if _distance > 0.0:
		audio_player = AudioStreamPlayer2D.new()
		audio_player.max_distance = _distance
		audio_player.position = _position
	else:
		audio_player = AudioStreamPlayer.new()
	
	add_child(audio_player)
	audio_player.finished.connect(audio_player.queue_free)
	audio_player.bus = "SFX"
	audio_player.volume_db = _volume
	audio_player.stream = audio_file
	
	if _vary:
		audio_player.pitch_scale = randf_range(0.8,1.2)
	
	audio_player.play()


func button_hover() -> void:
	play_sound(button_hover_sfx)
	

func button_click() -> void:
	play_sound(button_click_sfx)
	
	
func play_extractor_sound(_position: Vector2) -> void:
	play_sound(extractor_sfx,false, 600.0, _position)
	

func play_mead_maker_sound(_position: Vector2) -> void:
	play_sound(SFX_MEAD_MAKING,false, 600.0, _position)


func play_mead_pickup() -> void:
	play_sound(SFX_PACKAGE_MEAD,true)
	
	
func play_walking_sound() -> void:
	play_sound(walking_ground_sfx, true, 0.0, Vector2.ZERO,-4.0)


func play_bush_sfx() -> void:
	play_sound(SFX_WALKING_BUSHES,true)


func play_pickup_sound() -> void:
	play_sound(SFX_PICKUP_SOUND,true)
	

func play_bee_buzzing(_position: Vector2) -> void:
	play_sound(SFX_BEE_BUZZING_LOW,true,300,_position,10.0)


func play_money_sound() -> void:
	play_sound(SFX_MONEY_GAIN,true,0.0,Vector2.ZERO,-10.0)


func play_drop_honey() -> void:
	play_sound(SFX_DROP_HONEY_BUCKET,true,0.0,Vector2.ZERO,-1.0)


func play_error_sound() -> void:
	play_sound(ERROR_SOUND,true,0.0,Vector2.ZERO,-1.0)


func play_bear_placed() -> void:
	play_sound(BEAR_STATUE_PLACED,true)


func play_bear_golden() -> void:
	play_sound(BEAR_STATUE_GOLDEN,true)
	
	
func play_bear_offering() -> void:
	play_sound(BEAR_STATUE_OFFERING,true)


func play_bgm(audio_file: AudioStream, _volume: float = 0.0) -> void:
	bgm_player.stream = audio_file.duplicate() as AudioStream
	bgm_player.volume_db = _volume
	
	if is_playlist_active:
		bgm_player.stream.loop = false
	else:
		bgm_player.stream.loop = true
	
	bgm_player.play()
	
	
func stop_bgm() -> void:
	bgm_player.stop()


func play_title_bgm() -> void:
	if is_song_playing("1"):
		return
		
	is_playlist_active = false
	current_song_index = 1
	song_changed.emit(ost_playlist["1"].name,ost_playlist["1"].artist)
	play_bgm(ost_playlist["1"].song, ost_playlist["1"].volume)


func play_game_bgm() -> void:
	_fade_out_title()


func _fade_out_title() -> void:
	if bgm_player and bgm_player.playing:
		await _tween_volume(-80.0, 4)
		bgm_player.stop()
	
	start_playlist(2)


func _tween_volume(to_db: float, duration: float) -> void:
	if volume_tween:
		volume_tween.kill()
	
	volume_tween = create_tween()
	volume_tween.tween_property(bgm_player, "volume_db", to_db, duration)
	volume_tween.tween_interval(5)
	
	await volume_tween.finished


func _on_song_finished() -> void:
	if is_playlist_active:
		play_next_song()
		

func play_next_song() -> void:
	var start_index = current_song_index
	var playlist_size = ost_playlist.size()
	
	while true:
		current_song_index += 1
		
		if current_song_index > playlist_size:
			current_song_index = 1
			
		if current_song_index == start_index:
			is_playlist_active = false
			return
			
		if ost_playlist[str(current_song_index)].unlocked:
			play_bgm(ost_playlist[str(current_song_index)].song,ost_playlist[str(current_song_index)].volume)
			song_changed.emit(ost_playlist[str(current_song_index)].name, ost_playlist[str(current_song_index)].artist)
			return


func start_playlist(starting_index: int = 1) -> void:
	is_playlist_active = true
	current_song_index = starting_index - 1
	play_next_song()


func is_song_playing(song_key: String) -> bool:
	return bgm_player.playing and bgm_player.stream == ost_playlist[song_key].song
