extends StaticBody2D

signal placed
@onready var action_button: TextureButton = $ActionButton
@onready var action_button_label: Label = %ActionButtonLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	action_button.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_interactive_area_2d_body_entered(body: Node2D) -> void:
	if body is BeeKeeper:
		if body.holding != BeeKeeper.Holding.NOTHING:
			var bk = body as BeeKeeper
			action_button.show()
			match bk.holding:
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
					

func _on_interactive_area_2d_body_exited(body: Node2D) -> void:
	if body is BeeKeeper:
		action_button.hide()

func _on_action_button_pressed() -> void:
	placed.emit()
	pass # Replace with function body.
