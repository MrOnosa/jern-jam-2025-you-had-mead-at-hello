class_name GameWorld
extends Node2D

const BEE = preload("uid://ws0llatxgtev")

const NATURAL_HIVE_DRAGGABLE = preload("uid://dd56jcjuc6gn8")
const MAN_MADE_HIVE_DRAGGABLE = preload("uid://dsmlt42isfk6r")
const HONEY_EXTRACTOR_DRAGGABLE = preload("uid://88suwycgh5gw")
const BEE_COLONY = preload("uid://cnqxl80su0co4")
const MAN_MADE_BEE_COLONY = preload("uid://crwo4bniwcg18")
const HONEY_EXTRACTOR = preload("uid://cgbkpvg1ukgty")

@onready var cash_amount_label: Label = $HUD/PanelContainer/VBoxContainer/HBoxContainer/CashAmountLabel
@onready var bee_keeper: BeeKeeper = $BeeKeeper
@onready var panel_container: PanelContainer = $HUD/PanelContainer
@onready var natural_hive_button: TextureButton = $HUD/PanelContainer/VBoxContainer/NaturalHiveButton
@onready var man_made_hive_button: TextureButton = $HUD/PanelContainer/VBoxContainer/ManMadeHiveButton
@onready var honey_extractor_button: TextureButton = $HUD/PanelContainer/VBoxContainer/HoneyExtractorButton
@onready var sell_box: StaticBody2D = $Interactables/SellBox
@onready var ground: TextureRect = $GroundArea/Ground


enum Draggable_Items { NATURAL_BEE_HIVE, MAN_MADE_BEE_HIVE, HONEY_EXTRACTOR} 
@export var cash : int = 100
var mouse_is_over_HUD : bool = false
var mouse_is_within_window : bool = true
var drag_and_drop_item : Variant = null
var drag_and_drop_item_type : Draggable_Items
#const WORLD_GRASS_NOISE_TEXTURE = preload("uid://c0a00g37gmqql")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sell_box.placed.connect(_on_sell_box_placed)
	sell_box.placed.connect(bee_keeper._on_sell_box_placed)
	panel_container.mouse_entered.connect(_HUD_on_panel_container_mouse_entered)
	panel_container.mouse_exited.connect(_HUD_on_panel_container_mouse_exited)
	natural_hive_button.pressed.connect(_on_natural_hive_button_pressed)
	man_made_hive_button.pressed.connect(_on_man_made_hive_button_pressed)
	honey_extractor_button.pressed.connect(_on_honey_extractor_button_pressed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	cash_amount_label.text = str("$", Utility.add_commas_to_number(cash))
	if drag_and_drop_item != null && !drag_and_drop_item.is_queued_for_deletion():
		# https://www.reddit.com/r/godot/comments/yge1ms/comment/iucbhph/
		drag_and_drop_item.position = drag_and_drop_item.get_parent().get_local_mouse_position()
		drag_and_drop_item.modulate = Color.WHITE
		var any_collisions : bool = false
		if drag_and_drop_item.position.x > (ground.size.x-300) || drag_and_drop_item.position.y > (ground.size.y-70):
			any_collisions = true
			drag_and_drop_item.modulate = Color.INDIAN_RED
		if !mouse_is_over_HUD:
			var all_the_things = get_tree().get_nodes_in_group("too_close_bubble") as Array[Area2D]
			for b in all_the_things:
				if b.overlaps_area(drag_and_drop_item.get_node("InteractiveArea2D")):
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
						Draggable_Items.HONEY_EXTRACTOR:	
							var bee_colony = HONEY_EXTRACTOR.instantiate() as HoneyExtractor
							bee_colony.position = drag_and_drop_item.position
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
	
func _on_honey_extractor_button_pressed() -> void:
	drag_and_drop_item = HONEY_EXTRACTOR_DRAGGABLE.instantiate()
	drag_and_drop_item_type = Draggable_Items.HONEY_EXTRACTOR
	add_child(drag_and_drop_item)


func _HUD_on_panel_container_mouse_entered() -> void:
	mouse_is_over_HUD = true

func _HUD_on_panel_container_mouse_exited() -> void:
	mouse_is_over_HUD = false
