class_name SodaPickup
extends Node2D

@onready var soda_sprite: Sprite2D = %SodaSprite
@onready var soda_area_2d: Area2D = %SodaArea2D

const SODA_CAN = preload("uid://wierbtudhuho")
const SODA_CAN_2 = preload("uid://ctpk2i541jxt6")
const SODA_CAN_3 = preload("uid://blbnv2w1xw28k")
const SODA_CAN_4 = preload("uid://bos2xlj3k0y2v")

var soda_value: int = 5
var soda_sprite_list = [
	SODA_CAN, SODA_CAN_2, SODA_CAN_3, SODA_CAN_4
]

func _ready() -> void:
	soda_sprite.texture = soda_sprite_list.pick_random()
	rotation_degrees = randi_range(15,360)
	soda_area_2d.body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body is BeeKeeper:
		Utility.soda_can_picked_up.emit(soda_value)
		queue_free()
