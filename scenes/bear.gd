class_name Bear
extends StaticBody2D

const BEESWAX_TEXTURE_RECT = preload("uid://cgcicxyvpcpxd")
const MEAD_TEXTURE_RECT = preload("uid://devk4hm6v2wa")
const PACKED_HONEY_TEXTURE_RECT = preload("uid://bxgenrah1lasl")

@onready var offering_flow_container: HFlowContainer = %OfferingFlowContainer

@onready var info_panel: TextureRect = $InfoPanel
@onready var status_label: Label = $InfoPanel/StatusLabel
@onready var debug_rich_text_label: RichTextLabel = $DebugRichTextLabel

@onready var v_box_container: VBoxContainer = %VBoxContainer
@onready var honeycomb_action_button: TextureButton = $VBoxContainer/HoneycombActionButton
@onready var honey_action_button: TextureButton = $VBoxContainer/HoneyActionButton
@onready var beeswax_action_button: TextureButton = $VBoxContainer/BeeswaxActionButton

var player_nearby : BeeKeeper = null
var mouse_hovering : bool = false

var honeycombs : float = 0
var honey_jars : float = 0
var beeswax : float = 0

var offerings : int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	v_box_container.hide()
	honeycomb_action_button.hide()
	honey_action_button.hide()
	info_panel.hide()
	beeswax_action_button.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$DebugRichTextLabel.text = str("Offering: ", str(offerings))

	
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
		v_box_container.show()
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
		v_box_container.hide()
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
	var t = BEESWAX_TEXTURE_RECT.instantiate()
	offering_flow_container.add_child(t)
	var t2 = MEAD_TEXTURE_RECT.instantiate()
	offering_flow_container.add_child(t2)
	var t3 = PACKED_HONEY_TEXTURE_RECT.instantiate()
	offering_flow_container.add_child(t3)
	
	AudioManager.play_extractor_sound(global_position)
	honeycombs = min(3.0, honeycombs + 1.0)
	player_nearby.holding = BeeKeeper.Holding.NOTHING

func _on_honey_action_button_pressed() -> void:
	AudioManager.play_drop_honey()
	honey_jars = max(0.0, honey_jars - 1.0)
	player_nearby.holding = BeeKeeper.Holding.HONEY_HIGH

func _on_beeswax_action_button_pressed() -> void:
	AudioManager.play_pickup_sound()
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
