extends Node2D

const BEE = preload("uid://ws0llatxgtev")

const NATURAL_HONEY_HIVE_DRAGGABLE = preload("uid://dd56jcjuc6gn8")
const BEE_COLONY = preload("uid://cnqxl80su0co4")

@onready var bee_keeper: BeeKeeper = $BeeKeeper


var drag_and_drop_item : Variant = null
#const WORLD_GRASS_NOISE_TEXTURE = preload("uid://c0a00g37gmqql")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
#	var img = WORLD_GRASS_NOISE_TEXTURE.get_image()
#	img.save_png("user://somefile.png")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if drag_and_drop_item != null:
		# https://www.reddit.com/r/godot/comments/yge1ms/comment/iucbhph/
		drag_and_drop_item.position = drag_and_drop_item.get_parent().get_local_mouse_position()
		if Input.is_action_just_released("left_click"):
			var bee_colony = BEE_COLONY.instantiate() as BeeColony
			bee_colony.position = drag_and_drop_item.position
			bee_colony.total_bees = 8000
			bee_colony.raw_honey_produced = bee_colony.raw_honey_needed_for_a_jar - 0.1
			bee_colony.max_population = 20000
			bee_colony.max_raw_honey_capacity = bee_colony.raw_honey_needed_for_a_jar * 2
			bee_colony.honey_collected.connect(bee_keeper._on_bee_colony_honey_collected)
			bee_colony.spawn_bee.connect(_on_bee_colony_spawn_bee)
			add_child(bee_colony)
			drag_and_drop_item = null

func _on_bee_colony_spawn_bee(home_hive: BeeColony) -> void:	
	var bee : Bee = BEE.instantiate()
	bee.position = home_hive.get_node("ExitHiveMarker2D").global_position
	bee.home_hive = home_hive
	add_child(bee)

# GUI 
func _on_natural_bee_hive_button_pressed() -> void:
	var new_bee_colony = NATURAL_HONEY_HIVE_DRAGGABLE.instantiate()
	drag_and_drop_item = new_bee_colony
	add_child(drag_and_drop_item)
	pass # Replace with function body.
