class_name FloatingLeaf
extends Node2D

@onready var leaf_sprite: Sprite2D = %LeafSprite

var leaf_1: Texture2D = preload("uid://dukqun0sbuon")
var leaf_2: Texture2D = preload("uid://ceutjicpowrlc")
var leaf_3: Texture2D = preload("uid://ds5x2r5bu17pd")

var leaf_life: float = 15.0
var leaf_start_pos: Vector2
var leaf_end_pos: Vector2
var leaf_images = [
	leaf_1, leaf_2, leaf_3
]

func _ready() -> void:
	leaf_sprite.texture = leaf_images.pick_random()
	leaf_life = randf_range(15,60)
	leaf_start_pos = global_position
	leaf_end_pos = leaf_start_pos + Vector2(randf_range(1000,6400), randf_range(-500,500))
	
	fly_around()
	
	
func fly_around() -> void:
	var t_leaf = create_tween().set_trans(Tween.TRANS_SINE)
	t_leaf.tween_property(self, "modulate:a",1,3.0)
	t_leaf.parallel().tween_property(self, "rotation", randi_range(-90,90),leaf_life)
	t_leaf.parallel().tween_property(self, "global_position",leaf_end_pos,leaf_life)
	t_leaf.tween_callback(fade_leaf)
	

func fade_leaf() -> void:
	var t_leaf_end = create_tween().set_trans(Tween.TRANS_SINE)
	t_leaf_end.tween_property(self, "modulate:a",0,3.0)
	t_leaf_end.parallel().tween_property(self, "global_position:y", global_position.y + 10, 3.0)
	t_leaf_end.tween_callback(queue_free)
