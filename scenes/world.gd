extends Node2D

const BEE = preload("uid://ws0llatxgtev")

const NATURAL_HONEY_HIVE_DRAGGABLE = preload("uid://dd56jcjuc6gn8")
const BEE_COLONY = preload("uid://cnqxl80su0co4")

@onready var bee_keeper: BeeKeeper = $BeeKeeper


var mouse_is_over_HUD : bool = false
var drag_and_drop_item : Variant = null
#const WORLD_GRASS_NOISE_TEXTURE = preload("uid://c0a00g37gmqql")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
#	var img = WORLD_GRASS_NOISE_TEXTURE.get_image()
#	img.save_png("user://somefile.png")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if drag_and_drop_item != null && !drag_and_drop_item.is_queued_for_deletion():
		# https://www.reddit.com/r/godot/comments/yge1ms/comment/iucbhph/
		drag_and_drop_item.position = drag_and_drop_item.get_parent().get_local_mouse_position()
		drag_and_drop_item.modulate = Color.WHITE
		var any_collisions : bool = false
		if !mouse_is_over_HUD:
			var all_bee_colonies = get_tree().get_nodes_in_group("bee_colony") as Array[BeeColony]
			for b in all_bee_colonies:
				if b.get_node("InteractiveArea2D").overlaps_area(drag_and_drop_item.get_node("InteractiveArea2D")):
					any_collisions = true
					drag_and_drop_item.modulate = Color.INDIAN_RED
					break
		
		if  Input.is_action_just_released("left_click"):
			if !mouse_is_over_HUD:				
				# Check if the space is free				
				if any_collisions:
					#todo - Sfx that goes AANT!
					pass
				else:
					var bee_colony = BEE_COLONY.instantiate() as BeeColony
					bee_colony.position = drag_and_drop_item.position
					bee_colony.total_bees = 8000
					bee_colony.raw_honey_produced = bee_colony.raw_honey_needed_for_a_jar - 0.1
					bee_colony.max_population = 20000
					bee_colony.max_raw_honey_capacity = bee_colony.raw_honey_needed_for_a_jar * 2
					bee_colony.honey_collected.connect(bee_keeper._on_bee_colony_honey_collected)
					bee_colony.spawn_bee.connect(_on_bee_colony_spawn_bee)
					add_child(bee_colony)
			
			# Always clear this even if they are still over the hud.
			drag_and_drop_item.queue_free()

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


func _HUD_on_panel_container_mouse_entered() -> void:
	mouse_is_over_HUD = true


func _HUD_on_panel_container_mouse_exited() -> void:
	mouse_is_over_HUD = false
