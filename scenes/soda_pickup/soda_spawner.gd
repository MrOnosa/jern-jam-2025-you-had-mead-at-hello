class_name SodaSpawner
extends Node2D

@export var soda_item_scene: PackedScene
@export var soda_spawn_time: float = 120

@onready var soda_timer: Timer = %SodaTimer
@onready var soda_area: Area2D = %SodaArea

var disable_forever: bool = false
var can_spawn_here: bool = true
var item_here

func _ready() -> void:
	soda_timer.timeout.connect(_on_soda_timer_timeout)
	soda_area.body_entered.connect(_on_soda_area_entered)
	soda_area.body_exited.connect(_on_soda_area_exited)
	
	
func _on_soda_timer_timeout() -> void:
	if item_here:
		can_spawn_here = false
	else:
		can_spawn_here = true
		
	for child in get_children():
		if child is SodaPickup:
			can_spawn_here = false
			return
	
	if can_spawn_here:
		var soda: SodaPickup = soda_item_scene.instantiate()
		add_child(soda)
		await get_tree().create_timer(0.3).timeout
		var all_the_things = get_tree().get_nodes_in_group("too_close_bubble") as Array[Area2D]
		for b in all_the_things:
			if b.overlaps_area(soda.get_node("SodaArea2D")):
				soda.queue_free()
				disable_forever = true
				break
	
	if !disable_forever:
		soda_timer.start(randf_range(soda_spawn_time/2,soda_spawn_time))


func _on_soda_area_entered(body: Node2D) -> void:
	item_here = body
	
	
func _on_soda_area_exited(body: Node2D) -> void:
	item_here = null
