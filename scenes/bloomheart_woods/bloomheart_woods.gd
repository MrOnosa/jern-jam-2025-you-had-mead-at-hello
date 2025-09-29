class_name GameWorld
extends Node2D

# GUI
const NATURAL_HIVE_DRAGGABLE = preload("uid://dd56jcjuc6gn8")
const MAN_MADE_HIVE_DRAGGABLE = preload("uid://dsmlt42isfk6r")
const HONEY_EXTRACTOR_DRAGGABLE = preload("uid://88suwycgh5gw")
const BUCKET_DRAGGABLE = preload("uid://dcljkr1dxfu0g")
# Gameplay
const BEE = preload("uid://ws0llatxgtev")
const BEE_COLONY = preload("uid://cnqxl80su0co4")
const MAN_MADE_BEE_COLONY = preload("uid://crwo4bniwcg18")
const HONEY_EXTRACTOR = preload("uid://cgbkpvg1ukgty")
const BUCKET = preload("uid://dbh4sws1wru4s")

signal on_player_dragging_started
signal on_player_dragging_ended

@onready var hud: CanvasLayer = %HUD
@onready var cash_amount_label: Label = $HUD/NinePatchRect/VBoxContainer/HBoxContainer/CashAmountLabel
@onready var bee_keeper: BeeKeeper = $BeeKeeper
@onready var panel_container: NinePatchRect = $HUD/NinePatchRect
@onready var natural_hive_button: TextureButton = $HUD/NinePatchRect/VBoxContainer/NaturalHiveButton
@onready var man_made_hive_button: TextureButton = $HUD/NinePatchRect/VBoxContainer/ManMadeHiveButton
@onready var honey_extractor_button: TextureButton = $HUD/NinePatchRect/VBoxContainer/HoneyExtractorButton
@onready var bucket_button: TextureButton = $HUD/NinePatchRect/VBoxContainer/BucketButton
@onready var more_info_patch_rect: NinePatchRect = $HUD/MoreInfoPatchRect
@onready var rich_text_label: RichTextLabel = $HUD/MoreInfoPatchRect/MarginContainer/VBoxContainer/RichTextLabel
@onready var player_center_marker_2d: Marker2D = $PlayerCenterMarker2D

@onready var sell_box: StaticBody2D = $Interactables/SellBox
@onready var ground: TextureRect = $GroundArea/Ground

@export var cash : int = 100
var mouse_is_over_HUD : bool = false
var mouse_is_within_window : bool = true
var drag_and_drop_item : Variant = null
var drag_and_drop_item_type : Utility.Draggable_Items = Utility.Draggable_Items.VOID
#const WORLD_GRASS_NOISE_TEXTURE = preload("uid://c0a00g37gmqql")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AudioManager.play_game_bgm()
	
	sell_box.placed.connect(_on_sell_box_placed)
	sell_box.placed.connect(bee_keeper._on_sell_box_placed)
	panel_container.mouse_entered.connect(_HUD_on_panel_container_mouse_entered)
	panel_container.mouse_exited.connect(_HUD_on_panel_container_mouse_exited)
	natural_hive_button.pressed.connect(_on_natural_hive_button_pressed)
	man_made_hive_button.pressed.connect(_on_man_made_hive_button_pressed)
	honey_extractor_button.pressed.connect(_on_honey_extractor_button_pressed)
	bucket_button.pressed.connect(_on_bucket_button_pressed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Utility.sandbox_enabled:
		cash_amount_label.text = str("$$∞")
	else:
		cash_amount_label.text = str("$", Utility.add_commas_to_number(cash))
	
	if drag_and_drop_item_type != Utility.Draggable_Items.VOID:
		more_info_patch_rect.visible = true
	else:
		more_info_patch_rect.visible = false
		
	if drag_and_drop_item != null && !drag_and_drop_item.is_queued_for_deletion():
		# https://www.reddit.com/r/godot/comments/yge1ms/comment/iucbhph/
		drag_and_drop_item.position = drag_and_drop_item.get_parent().get_local_mouse_position()
		drag_and_drop_item.modulate = Color.WHITE
		var any_collisions : bool = false
		var too_expensive : bool = false
		if drag_and_drop_item.position.x > (ground.size.x-300) || drag_and_drop_item.position.y > (ground.size.y-70):
			any_collisions = true
			drag_and_drop_item.modulate = Color.INDIAN_RED
		if !mouse_is_over_HUD:
			# Can they even afford this thing?
			if Utility.draggable_items_dictionary()[drag_and_drop_item_type]["Cost"] > cash:
				too_expensive = true
				
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
					AudioManager.play_error_sound()
					hud.toast(str("Not enough room there"))
					pass
				elif too_expensive && !Utility.sandbox_enabled:
					AudioManager.play_error_sound()
					hud.toast(str("Need more cash \n", Utility.draggable_items_dictionary()[drag_and_drop_item_type]["Name"], " costs $", Utility.draggable_items_dictionary()[drag_and_drop_item_type]["Cost"]))
					pass
				else:
					# instantiate the item and deduct the cost from your cash
					match drag_and_drop_item_type:
						Utility.Draggable_Items.NATURAL_BEE_HIVE:
							var bee_colony = BEE_COLONY.instantiate() as BeeColony
							bee_colony.position = drag_and_drop_item.position
							bee_colony.total_bees = 8000
							bee_colony.raw_honey_produced = bee_colony.raw_honey_needed_for_a_jar / 2.2
							bee_colony.max_population = 20000
							bee_colony.max_raw_honey_capacity = bee_colony.raw_honey_needed_for_a_jar * 2
							bee_colony.honey_collected.connect(bee_keeper._on_bee_colony_honey_collected)
							bee_colony.spawn_bee.connect(_on_bee_colony_spawn_bee)
							
							if (!hud.placed_beehive):
								hud.placed_beehive = true
								hud.toast("More items available\nfor purchase", 5.0)
							
							add_child(bee_colony)
						Utility.Draggable_Items.MAN_MADE_BEE_HIVE:
							var bee_colony = MAN_MADE_BEE_COLONY.instantiate() as BeeColony
							bee_colony.position = drag_and_drop_item.position
							bee_colony.total_bees = 8000
							bee_colony.raw_honey_produced = bee_colony.raw_honey_needed_for_a_jar / 2.2
							bee_colony.max_population = 80000
							bee_colony.max_raw_honey_capacity = bee_colony.raw_honey_needed_for_a_jar * 6
							bee_colony.honey_collected.connect(bee_keeper._on_bee_colony_honey_collected)
							bee_colony.spawn_bee.connect(_on_bee_colony_spawn_bee)
							add_child(bee_colony)	
						Utility.Draggable_Items.HONEY_EXTRACTOR:	
							var bee_colony = HONEY_EXTRACTOR.instantiate() as HoneyExtractor
							bee_colony.position = drag_and_drop_item.position							
							
							if (!hud.placed_honey_extractor):
								hud.placed_honey_extractor = true
								hud.toast("More items available\nfor purchase", 5.0)
								
							add_child(bee_colony)	
						Utility.Draggable_Items.FOOD_GRADE_BUCKET:	
							var bee_colony = BUCKET.instantiate() as Bucket
							bee_colony.position = drag_and_drop_item.position
							add_child(bee_colony)					
						_:
							printerr("Huh?", drag_and_drop_item_type)
					
					if !Utility.sandbox_enabled:
						cash -= Utility.draggable_items_dictionary()[drag_and_drop_item_type]["Cost"]
					
			drag_and_drop_item_type = Utility.Draggable_Items.VOID
			# Always clear this even if they are still over the hud.
			drag_and_drop_item.queue_free()
			on_player_dragging_ended.emit()
		
	# Sales Box indicator
	player_center_marker_2d.global_position = bee_keeper.global_position
	var sale_box_locations = get_tree().get_nodes_in_group("sell_box")
	#	THIER CAN BE ONLY ONE
	if sale_box_locations.size() > 0:
		var angle_to_sales_box = player_center_marker_2d.global_position.angle_to_point(sale_box_locations[0].global_position)
		player_center_marker_2d.rotation = angle_to_sales_box
		if bee_keeper.holding != BeeKeeper.Holding.NOTHING && !sale_box_locations[0].visible_on_screen:
			var tween = player_center_marker_2d.create_tween()
			var new_position = Color("ffffff7f")
			tween.tween_property(player_center_marker_2d, "modulate", new_position, 0.7)
		else:
			var tween = player_center_marker_2d.create_tween()
			var new_position = Color.TRANSPARENT
			tween.tween_property(player_center_marker_2d, "modulate", new_position, 0.7)
		
func _on_bee_colony_spawn_bee(home_hive: BeeColony) -> void:	
	var bee : Bee = BEE.instantiate()
	bee.position = home_hive.get_node("ExitHiveMarker2D").global_position
	bee.home_hive = home_hive
	add_child(bee)


func _on_sell_box_placed(item_name: String, value: int) -> void:
	hud.toast(str("Sold! ", item_name," for $", value))
	cash += value


# GUI 
func _on_natural_hive_button_pressed() -> void:
	drag_and_drop_item = NATURAL_HIVE_DRAGGABLE.instantiate()
	drag_and_drop_item_type = Utility.Draggable_Items.NATURAL_BEE_HIVE
	rich_text_label.text = _build_more_info_rich_text(Utility.draggable_items_dictionary()[drag_and_drop_item_type])
	add_child(drag_and_drop_item)
	on_player_dragging_started.emit()

func _on_man_made_hive_button_pressed() -> void:
	drag_and_drop_item = MAN_MADE_HIVE_DRAGGABLE.instantiate()
	drag_and_drop_item_type = Utility.Draggable_Items.MAN_MADE_BEE_HIVE
	rich_text_label.text = _build_more_info_rich_text(Utility.draggable_items_dictionary()[drag_and_drop_item_type])
	add_child(drag_and_drop_item)
	on_player_dragging_started.emit()
	
func _on_honey_extractor_button_pressed() -> void:
	drag_and_drop_item = HONEY_EXTRACTOR_DRAGGABLE.instantiate()
	drag_and_drop_item_type = Utility.Draggable_Items.HONEY_EXTRACTOR	
	rich_text_label.text = _build_more_info_rich_text(Utility.draggable_items_dictionary()[drag_and_drop_item_type])
	add_child(drag_and_drop_item)
	on_player_dragging_started.emit()
	
func _on_bucket_button_pressed() -> void:
	drag_and_drop_item = BUCKET_DRAGGABLE.instantiate()
	drag_and_drop_item_type = Utility.Draggable_Items.FOOD_GRADE_BUCKET	
	rich_text_label.text = _build_more_info_rich_text(Utility.draggable_items_dictionary()[drag_and_drop_item_type])
	add_child(drag_and_drop_item)
	on_player_dragging_started.emit()

func _build_more_info_rich_text(info: Dictionary) -> String:
	var cost_text: String = str("Cost [b]$", info["Cost"], "[/b]")
	if Utility.sandbox_enabled:
		cost_text = str("Cost $[s]",info["Cost"],"[/s] Free - Sandbox Mode")	
	elif info["Cost"] > cash:
		cost_text = str(" [bgcolor=DB0000] ",cost_text," [/bgcolor] - Too expensive!")
	else:
		cost_text = str(" [bgcolor=288700] ",cost_text," [/bgcolor]")		
	return str(info["Name"], "\n", cost_text,"\n[hr]\n[indent]",info["Text"],"[/indent]")

func _HUD_on_panel_container_mouse_entered() -> void:
	mouse_is_over_HUD = true

func _HUD_on_panel_container_mouse_exited() -> void:
	mouse_is_over_HUD = false
