extends CanvasLayer

const TOAST_LABLE = preload("uid://bn6h1et37uvkd")
var dragging : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event):
	if dragging:
		if event is InputEventMouse || event is InputEventScreenDrag:
			if event.position.x > 165 && event.position.x < 538 &&  event.position.y < 290:
				%MoreInfoPatchRect.modulate = Color("ffffff7f")
			else:
				%MoreInfoPatchRect.modulate = Color.WHITE
			
			if event.position.x < 170:
				%NinePatchRect.modulate = Color("ffffff7f")
			else:
				%NinePatchRect.modulate = Color.WHITE
	else:
		%MoreInfoPatchRect.modulate = Color.WHITE
		%NinePatchRect.modulate = Color.WHITE


func _on_bloomheart_woods_on_player_dragging_started() -> void:
	dragging = true

func _on_bloomheart_woods_on_player_dragging_ended() -> void:
	dragging = false

func toast(message: String) -> void:
	var t = TOAST_LABLE.instantiate()
	t.position = Vector2(-200, 0)
	t.text = message
	add_child(t)
	var tween = t.create_tween()
	tween.set_ease(Tween.EASE_OUT)
	var new_position = t.position + Vector2(0, -100)
	tween.tween_property(t, "position", new_position, 3).set_trans(Tween.TRANS_EXPO )
	tween.tween_callback(t.queue_free)
	pass
