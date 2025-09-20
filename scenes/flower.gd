extends Area2D
class_name Flower

@export var total_pollen_available := 100
var pollen_available := 0
var being_harvested := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimatedSprite2D.frame = randi_range(0, 11)
	pollen_available = total_pollen_available
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

func _on_repollinate_timer_timeout() -> void:
	if !being_harvested:
		pollen_available = total_pollen_available
