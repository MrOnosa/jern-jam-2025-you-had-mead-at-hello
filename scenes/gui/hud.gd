extends CanvasLayer

@export var song_popup_scene: PackedScene

@onready var pause_menu: PauseMenu = %PauseMenu

const TOAST_LABLE = preload("uid://bn6h1et37uvkd")

@onready var natural_hive_button: TextureButton = %NaturalHiveButton
@onready var man_made_hive_button: TextureButton = %ManMadeHiveButton
@onready var honey_extractor_button: TextureButton = %HoneyExtractorButton
@onready var bear_button: TextureButton = %BearButton

@onready var bucket_button: TextureButton = %BucketButton
@onready var texture_progress_bar: TextureProgressBar = %TextureProgressBar
@onready var menu_button: TextureButton = %MenuButton



var dragging : bool = false

var placed_beehive : bool = false
var placed_honey_extractor : bool = false
var mead_ever_collected : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AudioManager.song_changed.connect(_on_song_changed)
	menu_button.pressed.connect(_on_menu_button_pressed)
	menu_button.mouse_entered.connect(AudioManager.button_hover)
	
	placed_beehive = Utility.sandbox_enabled
	placed_honey_extractor = Utility.sandbox_enabled
	mead_ever_collected = Utility.sandbox_enabled
	pause_menu.hide()

var tutorial_arrow_progress := 0.0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:		
	# Unlocked after placing a single beehive
	man_made_hive_button.visible = placed_beehive
	honey_extractor_button.visible = placed_beehive
	
	# Unlocked after placing a single honey extractor
	bucket_button.visible = placed_honey_extractor
	
	bear_button.visible = mead_ever_collected
	
	if !placed_beehive:
		tutorial_arrow_progress += delta * 100.0
		texture_progress_bar.value = min(100.0, tutorial_arrow_progress)
		if tutorial_arrow_progress > 200:
			tutorial_arrow_progress = 0
	else:
		texture_progress_bar.visible = false
	

func _input(event: InputEvent) -> void:
	if dragging:
		if event is InputEventMouse || event is InputEventScreenDrag:
			if event.position.x > 165 && event.position.x < 538 &&  event.position.y < 290:
				%MoreInfoPatchRect.modulate = Color("ffffff7f")
			else:
				%MoreInfoPatchRect.modulate = Color.WHITE
			
			if event.position.x < 170:
				%NinePatchRect.modulate = Color("ffffff7f")
			else:
				%NinePatchRect.modulate = Color.WHITE
	else:
		%MoreInfoPatchRect.modulate = Color.WHITE
		%NinePatchRect.modulate = Color.WHITE
		
	if event.is_action_pressed("pause_game") and not pause_menu.visible:
		AudioManager.button_click()
		pause_menu.show()
	elif event.is_action_pressed("pause_game") and pause_menu.visible:
		AudioManager.button_click()
		pause_menu.hide()


func _on_bloomheart_woods_on_player_dragging_started() -> void:
	dragging = true

func _on_bloomheart_woods_on_player_dragging_ended() -> void:
	dragging = false

func toast(message: String, _duration : float = 3.0) -> void:
	var t = TOAST_LABLE.instantiate()
	t.position = Vector2(-200, 0)
	t.text = message
	add_child(t)
	var tween = t.create_tween()
	tween.set_ease(Tween.EASE_OUT)
	var new_position = t.position + Vector2(0, -100)
	tween.tween_property(t, "position", new_position, _duration).set_trans(Tween.TRANS_EXPO )
	tween.tween_callback(t.queue_free)
	pass


func _on_song_changed(song_title: String, song_artist: String) -> void:
	var song_pop: SongPopup = song_popup_scene.instantiate()
	song_pop.composer_name = "Composer: " + song_artist
	song_pop.song_name = "Song: " + song_title
	add_child(song_pop)


func _on_menu_button_pressed() -> void:
	AudioManager.button_click()
	pause_menu.show()
