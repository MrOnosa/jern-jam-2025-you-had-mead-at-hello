extends Node2D

const BEE = preload("uid://ws0llatxgtev")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_spawn_bee_timer_timeout(source: Timer) -> void:
	var bee = BEE.instantiate()
	bee.position = Vector2(450,160)
	add_child(bee)
