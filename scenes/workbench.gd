extends StaticBody2D

signal placed
@onready var action_button: TextureButton = $ActionButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	z_index = int(global_position.y)
	action_button.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_interactive_area_2d_body_entered(body: Node2D) -> void:
	if body is BeeKeeper:
		if body.holding != BeeKeeper.Holding.NOTHING:
			action_button.show()

func _on_interactive_area_2d_body_exited(body: Node2D) -> void:
	if body is BeeKeeper:
		action_button.hide()

func _on_action_button_pressed() -> void:
	placed.emit()
	pass # Replace with function body.
