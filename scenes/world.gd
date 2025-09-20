extends Node2D

const BEE = preload("uid://ws0llatxgtev")
#const WORLD_GRASS_NOISE_TEXTURE = preload("uid://c0a00g37gmqql")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
#	var img = WORLD_GRASS_NOISE_TEXTURE.get_image()
#	img.save_png("user://somefile.png")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_spawn_bee_timer_timeout(source: Timer) -> void:
	var bee : Bee = BEE.instantiate()
	bee.position = $BeeColony/ExitHiveMarker2D.global_position
	bee.home_hive = $BeeColony
	add_child(bee)
