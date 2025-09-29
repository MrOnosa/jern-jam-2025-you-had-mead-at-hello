extends StaticBody2D

signal placed
@onready var action_button: TextureButton = $ActionButton
@onready var action_button_label: Label = %ActionButtonLabel
var visible_on_screen : bool = true
var player_nearby : BeeKeeper

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	action_button.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player_nearby != null:		
		action_button.visible = player_nearby.holding != BeeKeeper.Holding.NOTHING
		match player_nearby.holding:
			BeeKeeper.Holding.HONEY_HIGH:
				action_button_label.text = "Sell Honey"
			BeeKeeper.Holding.HONEYCOMB_HIGH:
				action_button_label.text = "Sell Honeycomb"
			BeeKeeper.Holding.BEESWAX:
				action_button_label.text = "Sell Beeswax"
			BeeKeeper.Holding.MEAD_HIGH:
				action_button_label.text = "Sell Mead"
			_:
				action_button_label.text = "Sell ???"
	else:
		action_button.hide()

func _on_interactive_area_2d_body_entered(body: Node2D) -> void:
	if body is BeeKeeper:
		player_nearby = body as BeeKeeper

func _on_interactive_area_2d_body_exited(body: Node2D) -> void:
	if body is BeeKeeper:
		player_nearby = null

func _on_action_button_pressed() -> void:
	if player_nearby != null:
		match player_nearby.holding:
			BeeKeeper.Holding.HONEY_HIGH:
				AudioManager.play_money_sound()
				placed.emit("Honey", 75)
			BeeKeeper.Holding.HONEYCOMB_HIGH:
				AudioManager.play_money_sound()
				placed.emit("Honeycomb", 50)
			BeeKeeper.Holding.BEESWAX:
				AudioManager.play_money_sound()
				placed.emit("Beeswax", 75)
			BeeKeeper.Holding.MEAD_HIGH:
				AudioManager.play_money_sound()
				placed.emit("Mead", 300)
			_:
				placed.emit("???", 0)
	pass # Replace with function body.


func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	visible_on_screen = true


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	visible_on_screen = false
