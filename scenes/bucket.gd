class_name Bucket
extends StaticBody2D

@onready var sprite_2d: Sprite2D = %Sprite2D
@onready var jar_1_texture_progress_bar: TextureProgressBar = %Jar1TextureProgressBar
@onready var jar_2_texture_progress_bar: TextureProgressBar = %Jar2TextureProgressBar
@onready var jar_3_texture_progress_bar: TextureProgressBar = %Jar3TextureProgressBar
@onready var high_quality_mead_texture_progress_bar_1: TextureProgressBar = $InfoPanel/VBoxContainer/BottomHBoxContainer/HighQualityMeadTextureProgressBar1
@onready var high_quality_mead_texture_progress_bar_2: TextureProgressBar = $InfoPanel/VBoxContainer/BottomHBoxContainer/HighQualityMeadTextureProgressBar2

@onready var info_panel: TextureRect = $InfoPanel
@onready var status_label: Label = $InfoPanel/StatusLabel
@onready var debug_rich_text_label: RichTextLabel = $DebugRichTextLabel

@onready var honey_action_button: TextureButton = $VBoxContainer/HoneyActionButton
@onready var mead_action_button: TextureButton = $VBoxContainer/MeadActionButton


var player_nearby : BeeKeeper = null
var mouse_hovering : bool = false

enum Fermentation_Statuses { IDLE, IN_PROGRESS }
var fermentation_status : Fermentation_Statuses = Fermentation_Statuses.IDLE

var fermentation_progress : int = 0
var honey_jars : int = 0
var mead : int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	honey_action_button.hide()
	mead_action_button.hide()
	info_panel.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$DebugRichTextLabel.text = str("H: ", str(honey_jars), "\nM: ", str(mead))
	
	if fermentation_status == Fermentation_Statuses.IN_PROGRESS:
		sprite_2d.position = Vector2(10 * sin(delta), 10 * cos(delta)) 
		# As the fermentation process occures, slowly drain ALL the jars of honey
		var value_for_the_lot = 100.0 - fermentation_progress
		jar_1_texture_progress_bar.value = value_for_the_lot
		jar_1_texture_progress_bar.modulate = Color.WHITE if jar_1_texture_progress_bar.value > 0 else Color.TRANSPARENT
		jar_2_texture_progress_bar.value = value_for_the_lot
		jar_2_texture_progress_bar.modulate = Color.WHITE if jar_2_texture_progress_bar.value > 0 else Color.TRANSPARENT	
		jar_3_texture_progress_bar.value = value_for_the_lot
		jar_3_texture_progress_bar.modulate = Color.WHITE if jar_3_texture_progress_bar.value > 0 else Color.TRANSPARENT
		
		var value_for_meads = fermentation_progress	# Fill each mead bottle			
		high_quality_mead_texture_progress_bar_1.value = value_for_meads
		high_quality_mead_texture_progress_bar_1.modulate = Color.WHITE if high_quality_mead_texture_progress_bar_1.value > 0 else Color.TRANSPARENT
		high_quality_mead_texture_progress_bar_2.value = value_for_meads
		high_quality_mead_texture_progress_bar_2.modulate = Color.WHITE if high_quality_mead_texture_progress_bar_2.value > 0 else Color.TRANSPARENT	
		
	elif fermentation_status == Fermentation_Statuses.IDLE:
		sprite_2d.position = Vector2.ZERO
		# Fill each jar with honey	
		jar_1_texture_progress_bar.value = min(100, honey_jars * 100)
		jar_1_texture_progress_bar.modulate = Color.WHITE if jar_1_texture_progress_bar.value > 0 else Color.TRANSPARENT
		jar_2_texture_progress_bar.value = min(100, (honey_jars - 1) * 100)
		jar_2_texture_progress_bar.modulate = Color.WHITE if jar_2_texture_progress_bar.value > 0 else Color.TRANSPARENT	
		jar_3_texture_progress_bar.value = min(100, (honey_jars - 2) * 100)
		jar_3_texture_progress_bar.modulate = Color.WHITE if jar_3_texture_progress_bar.value > 0 else Color.TRANSPARENT
			# Fill each mead bottle			
		high_quality_mead_texture_progress_bar_1.value = calc_mead_percent(0)
		high_quality_mead_texture_progress_bar_1.modulate = Color.WHITE if high_quality_mead_texture_progress_bar_1.value > 0 else Color.TRANSPARENT
		high_quality_mead_texture_progress_bar_2.value = calc_mead_percent(1)
		high_quality_mead_texture_progress_bar_2.modulate = Color.WHITE if high_quality_mead_texture_progress_bar_2.value > 0 else Color.TRANSPARENT	

	if fermentation_status == Fermentation_Statuses.IN_PROGRESS:
		status_label.text = "Fermentation in progress..."
	elif mead > 0:
		status_label.text = "Mead is ready"
		if player_nearby != null && player_nearby.holding != BeeKeeper.Holding.NOTHING:
			status_label.text = "Mead is ready - Your hands are full"
	elif honey_jars > 0:
		status_label.text = "Currently Idle - Needs more honey"
	#elif honey_jars == 0:
		#status_label.text = "Currently Idle - Needs honey"
	else:
		status_label.text = "Currently Idle - Needs honey"
		
	
	if player_nearby != null:
		info_panel.show()
		if player_nearby.holding == BeeKeeper.Holding.HONEY_HIGH \
		&& honey_jars < 3 \
		&& mead == 0 \
		&& fermentation_status != Fermentation_Statuses.IN_PROGRESS: #
			honey_action_button.show()
		else:
			honey_action_button.hide()
		
		if player_nearby.holding == BeeKeeper.Holding.NOTHING \
		  && mead > 0 \
		  && fermentation_status != Fermentation_Statuses.IN_PROGRESS:
			mead_action_button.show()
		else:
			mead_action_button.hide()						
	else:
		honey_action_button.hide()
		mead_action_button.hide()
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

func _on_honey_action_button_pressed() -> void:
	honey_jars = min(3, honey_jars + 1)
	player_nearby.holding = BeeKeeper.Holding.NOTHING
	
func _on_mead_action_button_pressed() -> void:
	mead = max(0, mead - 1)
	if mead == 0:
		fermentation_progress = 0
		fermentation_status = Fermentation_Statuses.IDLE
	player_nearby.holding = BeeKeeper.Holding.MEAD_HIGH	

func _on_do_work_timer_timeout() -> void:
	if fermentation_progress >= 100 && fermentation_status == Fermentation_Statuses.IN_PROGRESS:
		mead = 2
		honey_jars = 0
		fermentation_progress = 0
		fermentation_status = Fermentation_Statuses.IDLE
	elif fermentation_status == Fermentation_Statuses.IN_PROGRESS:
		var conversion_ratio = 3 
		fermentation_progress = min(100, fermentation_progress + conversion_ratio)	
	elif honey_jars >= 3 && fermentation_status != Fermentation_Statuses.IN_PROGRESS:
		fermentation_progress = 1
		fermentation_status = Fermentation_Statuses.IN_PROGRESS

func calc_mead_percent(mead_index: float) -> float:
	return min(100.0,( mead - mead_index) * 100.0)
