extends StaticBody2D
class_name BeeColony

var pollen_collected := 0
var honey_produced := 0

signal honey_collected
@onready var action_button: TextureButton = $ActionButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	action_button.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _on_interactive_area_2d_body_entered(body: Node2D) -> void:
	if body is BeeKeeper:
		if honey_produced > 0:
			action_button.show()


func _on_interactive_area_2d_body_exited(body: Node2D) -> void:
	if body is BeeKeeper:
		action_button.hide()


func _on_action_button_pressed() -> void:
	# For now always collect high quality honey
	honey_collected.emit()
