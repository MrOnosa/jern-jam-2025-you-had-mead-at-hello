class_name HoneyExtractor
extends StaticBody2D

@onready var sprite_2d: Sprite2D = %Sprite2D
@onready var honeycomb_1_texture_progress_bar: TextureProgressBar = %Honeycomb1TextureProgressBar
@onready var honeycomb_2_texture_progress_bar: TextureProgressBar = %Honeycomb2TextureProgressBar
@onready var honeycomb_3_texture_progress_bar: TextureProgressBar = %Honeycomb3TextureProgressBar
@onready var jar_1_texture_progress_bar: TextureProgressBar = %Jar1TextureProgressBar
@onready var jar_2_texture_progress_bar: TextureProgressBar = %Jar2TextureProgressBar
@onready var jar_3_texture_progress_bar: TextureProgressBar = %Jar3TextureProgressBar
@onready var beeswax_1_texture_progress_bar: TextureProgressBar = %Beeswax1TextureProgressBar
@onready var beeswax_2_texture_progress_bar: TextureProgressBar = %Beeswax2TextureProgressBar
@onready var beeswax_3_texture_progress_bar: TextureProgressBar = %Beeswax3TextureProgressBar

@onready var info_panel: TextureRect = $InfoPanel
@onready var status_label: Label = $InfoPanel/StatusLabel
@onready var debug_rich_text_label: RichTextLabel = $DebugRichTextLabel

@onready var honeycomb_action_button: TextureButton = $VBoxContainer/HoneycombActionButton
@onready var honey_action_button: TextureButton = $VBoxContainer/HoneyActionButton
@onready var beeswax_action_button: TextureButton = $VBoxContainer/BeeswaxActionButton
@onready var extractor_sound: AudioStreamPlayer2D = %ExtractorSound

var player_nearby : BeeKeeper = null
var mouse_hovering : bool = false

var honeycombs : float = 0
var honey_jars : float = 0
var beeswax : float = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	honeycomb_action_button.hide()
	honey_action_button.hide()
	info_panel.hide()
	beeswax_action_button.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$DebugRichTextLabel.text = str("HC: ", str(honeycombs), "\nH: ", str(honey_jars), "\nBx: ", beeswax)
	
	if honeycombs > 0.0:
		sprite_2d.position = Vector2(randf_range(-2,2),randf_range(-2,2))
	else:
		sprite_2d.position = Vector2.ZERO
	# Fill honeycomb textures		
	honeycomb_1_texture_progress_bar.value = calc_honeycomb_percent(0)
	honeycomb_1_texture_progress_bar.modulate = Color.WHITE if honeycomb_1_texture_progress_bar.value > 0 else Color.TRANSPARENT
	honeycomb_2_texture_progress_bar.value = calc_honeycomb_percent(1)
	honeycomb_2_texture_progress_bar.modulate = Color.WHITE if honeycomb_2_texture_progress_bar.value > 0 else Color.TRANSPARENT
	honeycomb_3_texture_progress_bar.value = calc_honeycomb_percent(2)
	honeycomb_3_texture_progress_bar.modulate = Color.WHITE if honeycomb_3_texture_progress_bar.value > 0 else Color.TRANSPARENT
		
	# Fill each jar with honey			
	jar_1_texture_progress_bar.value = calc_jar_percent(0)
	jar_1_texture_progress_bar.modulate = Color.WHITE if jar_1_texture_progress_bar.value > 0 else Color.TRANSPARENT
	jar_2_texture_progress_bar.value = calc_jar_percent(1)
	jar_2_texture_progress_bar.modulate = Color.WHITE if jar_2_texture_progress_bar.value > 0 else Color.TRANSPARENT	
	jar_3_texture_progress_bar.value = calc_jar_percent(2)
	jar_3_texture_progress_bar.modulate = Color.WHITE if jar_3_texture_progress_bar.value > 0 else Color.TRANSPARENT
	
	# Fill each beexwax			
	beeswax_1_texture_progress_bar.value = calc_beeswax_percent(0)
	beeswax_1_texture_progress_bar.modulate = Color.WHITE if beeswax_1_texture_progress_bar.value > 0 else Color.TRANSPARENT
	beeswax_2_texture_progress_bar.value = calc_beeswax_percent(1)
	beeswax_2_texture_progress_bar.modulate = Color.WHITE if beeswax_2_texture_progress_bar.value > 0 else Color.TRANSPARENT	
	beeswax_3_texture_progress_bar.value = calc_beeswax_percent(2)
	beeswax_3_texture_progress_bar.modulate = Color.WHITE if beeswax_3_texture_progress_bar.value > 0 else Color.TRANSPARENT
	
	
	if honey_jars == 3:
		status_label.text = "Currently Full of Honey"
	elif beeswax == 3:
		status_label.text = "Currently Full of Beeswax"
	elif player_nearby != null \
	&& player_nearby.holding != BeeKeeper.Holding.NOTHING \
	&& player_nearby.holding != BeeKeeper.Holding.HONEYCOMB_HIGH \
	&& (honey_jars > 0 || beeswax > 0) :
		status_label.text = "Your hands are full"
	elif honeycombs == 0:
		status_label.text = "Currenly Idle - Needs honeycomb"
	else:
		status_label.text = "Extracting honey and beeswax"
		
	
	if player_nearby != null:
		info_panel.show()
		if player_nearby.holding == BeeKeeper.Holding.HONEYCOMB_HIGH \
		&& honeycombs <= 2.01 \
		&& honey_jars + honeycombs <= 2.01  \
		&& beeswax + honeycombs <= 2.01 : #For some reason, comparing to 2.0 runs in to issues
			honeycomb_action_button.show()
		else:
			honeycomb_action_button.hide()
		
		if player_nearby.holding == BeeKeeper.Holding.NOTHING \
		  && honey_jars >= 0.99: #For some reason, comparing to 1.0 runs in to issues
			honey_action_button.show()
		else:
			honey_action_button.hide()	
			
		if player_nearby.holding == BeeKeeper.Holding.NOTHING \
		  && beeswax >= 0.99:
			beeswax_action_button.show()
		else:
			beeswax_action_button.hide()			
	else:
		honeycomb_action_button.hide()
		honey_action_button.hide()
		beeswax_action_button.hide()
		info_panel.hide()
	
	if Input.is_action_pressed("show_all_stats_key") || mouse_hovering:
		info_panel.show()

func _on_interactive_area_2d_body_entered(body: Node2D) -> void:
	if body is BeeKeeper:
		player_nearby = body

func _on_interactive_area_2d_body_exited(body: Node2D) -> void:
	if body is BeeKeeper:
		player_nearby = null

func _on_mouse_entered() -> void:
	mouse_hovering = true

func _on_mouse_exited() -> void:
	mouse_hovering = false

func _on_honeycomb_action_button_pressed() -> void:
	extractor_sound.play()
	honeycombs = min(3.0, honeycombs + 1.0)
	player_nearby.holding = BeeKeeper.Holding.NOTHING

func _on_honey_action_button_pressed() -> void:
	honey_jars = max(0.0, honey_jars - 1.0)
	player_nearby.holding = BeeKeeper.Holding.HONEY_HIGH

func _on_beeswax_action_button_pressed() -> void:
	beeswax = max(0.0, beeswax - 1.0)
	player_nearby.holding = BeeKeeper.Holding.BEESWAX

func _on_do_work_timer_timeout() -> void:
	if honeycombs > 0:
		var conversion_ratio = 0.075
		var honeycomb_delta = conversion_ratio if honeycombs >= conversion_ratio else honeycombs
		honeycombs -= honeycomb_delta
		honey_jars = min(3, honey_jars + honeycomb_delta)
		beeswax = min(3, honeycomb_delta + beeswax)
		

func calc_honeycomb_percent(honeycomb_index: float) -> float:
	return min(100.0,( honeycombs - honeycomb_index) * 100.0)

func calc_jar_percent(jar_index: float) -> float:
	return min(100.0,( honey_jars - jar_index) * 100.0)
	
func calc_beeswax_percent(beeswax_index: float) -> float:
	return min(100.0,( beeswax - beeswax_index) * 100.0)
