extends Area2D
class_name Flower

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_body_entered(body: Node2D, source: Flower) -> void:
	if body is Bee:
		body.notice_flower(source)

func _on_body_exited(body: Node2D, source: Flower) -> void:
	if body is Bee:
		body.left_flower(source)
