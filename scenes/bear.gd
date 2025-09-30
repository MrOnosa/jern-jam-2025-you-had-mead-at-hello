class_name Bear
extends StaticBody2D

const BEESWAX_TEXTURE_RECT = preload("uid://cgcicxyvpcpxd")
const MEAD_TEXTURE_RECT = preload("uid://devk4hm6v2wa")
const PACKED_HONEY_TEXTURE_RECT = preload("uid://bxgenrah1lasl")

signal bear_turned_golden

@onready var offering_flow_container: HFlowContainer = %OfferingFlowContainer

@onready var header_label: Label = $InfoPanel/HeaderLabel
@onready var info_panel: TextureRect = $InfoPanel
@onready var status_label: Label = $InfoPanel/StatusLabel
@onready var debug_rich_text_label: RichTextLabel = $DebugRichTextLabel
@onready var texture_progress_bar: TextureProgressBar = $AnchorNode/TextureProgressBar



@onready var action_button: TextureButton = $ActionButton
@onready var action_button_label: Label = %ActionButtonLabel

var player_nearby : BeeKeeper = null
var mouse_hovering : bool = false

# Value of all the offerings so far
var offerings : int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:	
	info_panel.hide()
	action_button.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$DebugRichTextLabel.text = str("Offering: ", str(offerings))
	$AnchorNode/TextureProgressBar.value = min(100, offerings)
	if offerings >= 100:
		header_label.text = "Golden Bear"
		status_label.text = "This bear now protects the forrest"
	elif player_nearby != null \
	&& (player_nearby.holding == BeeKeeper.Holding.HONEY_HIGH \
		|| player_nearby.holding == BeeKeeper.Holding.BEESWAX \
		|| player_nearby.holding == BeeKeeper.Holding.MEAD_HIGH) \
	:
		status_label.text = "The bear likes what you are holding"
		match player_nearby.holding:
			BeeKeeper.Holding.HONEY_HIGH:
				%ActionButtonLabel.text = "Offer Honey"
			BeeKeeper.Holding.BEESWAX:
				%ActionButtonLabel.text = "Offer Beeswax"
			BeeKeeper.Holding.MEAD_HIGH:
				%ActionButtonLabel.text = "Offer Mead"
			_:
				action_button_label.text = "Offer ???"
	elif player_nearby != null \
	&& player_nearby.holding != BeeKeeper.Holding.NOTHING:
		status_label.text = "The bear wants something else..."
	elif offerings > 0:
		header_label.text = str("Bear - %", min(100, offerings))
		status_label.text = "Turning gold with each offering"
	else:
		header_label.text = "Bear"
		status_label.text = "Offer honey, beeswax, or mead"
		
	
	if player_nearby != null:
		info_panel.show()
		if offerings < 100 && (player_nearby.holding == BeeKeeper.Holding.HONEY_HIGH \
		|| player_nearby.holding == BeeKeeper.Holding.BEESWAX \
		|| player_nearby.holding == BeeKeeper.Holding.MEAD_HIGH) : #For some reason, comparing to 2.0 runs in to issues
			action_button.show()
		else:
			action_button.hide()				
	else:
		action_button.hide()
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

func _on_action_button_pressed() -> void:
	if player_nearby != null:
		if player_nearby.holding == BeeKeeper.Holding.BEESWAX:
			offerings = min(100, offerings + 2)
			var t = BEESWAX_TEXTURE_RECT.instantiate()
			offering_flow_container.add_child(t)		
		if player_nearby.holding == BeeKeeper.Holding.HONEY_HIGH:
			offerings = min(100, offerings + 3)
			var t = PACKED_HONEY_TEXTURE_RECT.instantiate()
			offering_flow_container.add_child(t)
		if player_nearby.holding == BeeKeeper.Holding.MEAD_HIGH:
			offerings = min(100, offerings + 7)
			var t = MEAD_TEXTURE_RECT.instantiate()
			offering_flow_container.add_child(t)
	
	if offerings < 100:
		AudioManager.play_bear_offering()
	elif offerings >= 100:
		AudioManager.play_bear_golden()
		bear_turned_golden.emit()
		
	player_nearby.holding = BeeKeeper.Holding.NOTHING
