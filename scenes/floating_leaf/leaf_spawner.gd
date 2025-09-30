class_name LeafSpawner
extends Node2D

@onready var leaf_spawn_timer: Timer = %LeafSpawnTimer

@export var leaf_scene: PackedScene
@export var spawn_amount: int = 50 # how many to spawn at a time?
@export var leaf_life_low: float = 15.0 # how long will leaves last minimally?
@export var leaf_life_high: float = 60.0 # how long will leaves last maximum?
@export var spawn_interval: float = 30.0


func _ready() -> void:
	leaf_spawn_timer.timeout.connect(_on_leaf_spawn_timer_timeout)
	leaf_spawn_timer.wait_time = randf_range(spawn_interval/2,spawn_interval)
	
	spawn_leaves()
	
	
func spawn_leaves() -> void:
	for leaf in spawn_amount:
		var leaf_item: FloatingLeaf = leaf_scene.instantiate()
		leaf_item.leaf_life = randf_range(leaf_life_low, leaf_life_high)
		add_child(leaf_item)
		leaf_item.global_position = Vector2(randf_range(-50,50), randf_range(-50,3300))


func _on_leaf_spawn_timer_timeout() -> void:
	spawn_leaves()
	leaf_spawn_timer.wait_time = randf_range(spawn_interval/2,spawn_interval)
	leaf_spawn_timer.start()
