extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	bee_navigate_generator()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func bee_navigate_generator() -> void:
	var subtween_spin = create_tween()
	subtween_spin.tween_property(self, "rotation_degrees", 45.0, randf_range(0.5, 1.5)).set_trans(Tween.TRANS_SINE ) 
	subtween_spin.tween_property(self, "rotation_degrees", 0.0, randf_range(0.5, 1.5)).set_trans(Tween.TRANS_SINE )
	
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", world_clamp(position + Vector2(randi_range(-10, 10), randi_range(-10, 30))), randf_range(0.5, 1.5)).set_trans(Tween.TRANS_SINE )
	tween.tween_subtween(subtween_spin)
	tween.tween_property(self, "position", world_clamp(position + Vector2(randi_range(-50, 50), randi_range(-100, 300))), randf_range(0.5, 1.5)).set_trans(Tween.TRANS_SINE )
	tween.tween_callback(bee_navigate_generator)
	
func world_clamp(vector: Vector2) -> Vector2:
	return Vector2(clamp(vector.x, 0, 13000 * .3), clamp(vector.y, 0, 8000 * .3))
