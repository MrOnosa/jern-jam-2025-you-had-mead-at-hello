extends Node2D

const BEE = preload("uid://ws0llatxgtev")

const NATURAL_HIVE_DRAGGABLE = preload("uid://dd56jcjuc6gn8")
const MAN_MADE_HIVE_DRAGGABLE = preload("uid://dsmlt42isfk6r")
const BEE_COLONY = preload("uid://cnqxl80su0co4")
const MAN_MADE_BEE_COLONY = preload("uid://crwo4bniwcg18")

@onready var cash_amount_label: Label = %CashAmountLabel
@onready var bee_keeper: BeeKeeper = $BeeKeeper


enum Draggable_Items { NATURAL_BEE_HIVE, MAN_MADE_BEE_HIVE} 
@export var cash : int = 100
var mouse_is_over_HUD : bool = false
var mouse_is_within_window : bool = true
var drag_and_drop_item : Variant = null
var drag_and_drop_item_type : Draggable_Items
#const WORLD_GRASS_NOISE_TEXTURE = preload("uid://c0a00g37gmqql")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
#	var img = WORLD_GRASS_NOISE_TEXTURE.get_image()
#	img.save_png("user://somefile.png")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	cash_amount_label.text = str("$", Utility.add_commas_to_number(cash))
	if drag_and_drop_item != null && !drag_and_drop_item.is_queued_for_deletion():
		# https://www.reddit.com/r/godot/comments/yge1ms/comment/iucbhph/
		drag_and_drop_item.position = drag_and_drop_item.get_parent().get_local_mouse_position()
		drag_and_drop_item.modulate = Color.WHITE
		var any_collisions : bool = false
		if !mouse_is_over_HUD:
			var all_the_things = get_tree().get_nodes_in_group("too_close_bubble") as Array[Area2D]
			for b in all_the_things:
				if b.overlaps_area(drag_and_drop_item.get_node("InteractiveArea2D")):
					any_collisions = true
					drag_and_drop_item.modulate = Color.INDIAN_RED
					break
		
		if  Input.is_action_just_released("left_click"):
			if !mouse_is_over_HUD && mouse_is_within_window:				
				# Check if the space is free				
				if any_collisions:
					#todo - Sfx that goes AANT!
					pass
				else:
					match drag_and_drop_item_type:
						Draggable_Items.NATURAL_BEE_HIVE:
							var bee_colony = BEE_COLONY.instantiate() as BeeColony
							bee_colony.position = drag_and_drop_item.position
							bee_colony.total_bees = 8000
							bee_colony.raw_honey_produced = bee_colony.raw_honey_needed_for_a_jar - 0.1
							bee_colony.max_population = 20000
							bee_colony.max_raw_honey_capacity = bee_colony.raw_honey_needed_for_a_jar * 2
							bee_colony.honey_collected.connect(bee_keeper._on_bee_colony_honey_collected)
							bee_colony.spawn_bee.connect(_on_bee_colony_spawn_bee)
							add_child(bee_colony)	
						Draggable_Items.MAN_MADE_BEE_HIVE:	
							var bee_colony = MAN_MADE_BEE_COLONY.instantiate() as BeeColony
							bee_colony.position = drag_and_drop_item.position
							bee_colony.total_bees = 8000
							bee_colony.raw_honey_produced = bee_colony.raw_honey_needed_for_a_jar - 0.1
							bee_colony.max_population = 80000
							bee_colony.max_raw_honey_capacity = bee_colony.raw_honey_needed_for_a_jar * 6
							bee_colony.honey_collected.connect(bee_keeper._on_bee_colony_honey_collected)
							bee_colony.spawn_bee.connect(_on_bee_colony_spawn_bee)
							add_child(bee_colony)					
						_:
							printerr("Huh?", drag_and_drop_item_type)
			
			# Always clear this even if they are still over the hud.
			drag_and_drop_item.queue_free()
		
func _on_bee_colony_spawn_bee(home_hive: BeeColony) -> void:	
	var bee : Bee = BEE.instantiate()
	bee.position = home_hive.get_node("ExitHiveMarker2D").global_position
	bee.home_hive = home_hive
	add_child(bee)


func _on_sell_box_placed() -> void:
	print("Sold!")
	cash += 100
	pass # Replace with function body.


# GUI 
func _on_natural_hive_button_pressed() -> void:
	drag_and_drop_item = NATURAL_HIVE_DRAGGABLE.instantiate()
	drag_and_drop_item_type = Draggable_Items.NATURAL_BEE_HIVE
	add_child(drag_and_drop_item)

func _on_man_made_hive_button_pressed() -> void:
	drag_and_drop_item = MAN_MADE_HIVE_DRAGGABLE.instantiate()
	drag_and_drop_item_type = Draggable_Items.MAN_MADE_BEE_HIVE
	add_child(drag_and_drop_item)


func _HUD_on_panel_container_mouse_entered() -> void:
	mouse_is_over_HUD = true


func _HUD_on_panel_container_mouse_exited() -> void:
	mouse_is_over_HUD = false


func _on_mouse_in_window_area_2d_mouse_entered() -> void:
	mouse_is_within_window = true


func _on_mouse_in_window_area_2d_mouse_exited() -> void:
	mouse_is_within_window = false
