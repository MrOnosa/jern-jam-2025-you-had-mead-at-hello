extends StaticBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func beekeeper_nearby() -> void:
	print_debug("Frog nearby")
	pass


func _on_interactive_area_2d_body_entered(body: Node2D) -> void:
	if body is BeeKeeper:
		print_debug("Beekeeper nearby!")


func _on_interactive_area_2d_body_exited(body: Node2D) -> void:
	if body is BeeKeeper:
		print_debug("Beekeeper left me =(")
