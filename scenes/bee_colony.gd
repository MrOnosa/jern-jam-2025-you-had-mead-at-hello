class_name BeeColony
extends StaticBody2D

@onready var honeycomb_texture_progress_bar_1: TextureProgressBar = %HoneycombTextureProgressBar1
@onready var honeycomb_texture_progress_bar_2: TextureProgressBar = %HoneycombTextureProgressBar2
@onready var honeycomb_texture_progress_bar_3: TextureProgressBar = %HoneycombTextureProgressBar3
@onready var honeycomb_texture_progress_bar_4: TextureProgressBar = %HoneycombTextureProgressBar4
@onready var honeycomb_texture_progress_bar_5: TextureProgressBar = %HoneycombTextureProgressBar5
@onready var honeycomb_texture_progress_bar_6: TextureProgressBar = %HoneycombTextureProgressBar6


@onready var action_button: TextureButton = $ActionButton
@onready var info_panel: TextureRect = $InfoPanel
@onready var status_label: Label = $InfoPanel/StatusLabel

@export var pollen_needed_to_produce_one_raw_honey := 10
@export var pollen_collected := 0
@export var max_raw_honey_capacity := 360.0 # raw_honey_needed_for_a_jar * 6
@export var raw_honey_needed_for_a_jar := 60.0
@export var raw_honey_produced := 0.0
@export var raw_honey_consumption_ratio := (1/50000.0)
@export var bee_growth := 250

@export var total_bees := 10000
@export var max_population := 80000
@export var bees_to_sprite_threshold := 2000.0 # How many bees do you need to see a sprite of a bee in the wild

@export var bees_needed_to_convert_pollen_to_honey := 10000

var player_nearby : BeeKeeper = null
var mouse_hovering : bool = false
var is_starving : bool = false

signal honey_collected
signal spawn_bee(home_hive: BeeColony)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	action_button.hide()
	info_panel.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var food_needed := total_bees * raw_honey_consumption_ratio
	$DebugRichTextLabel.text = str("PC: ", str(pollen_collected), "\nRHP: ", str(raw_honey_produced), "\nPop: ", total_bees, "\nFN: ", food_needed)
	$InfoPanel/PopulationLabel.text = str("Population: ", Utility.add_commas_to_number(total_bees))
	
	$InfoPanel/StarvingLabel.visible = is_starving
	
	# Fill each jar with honey			
	honeycomb_texture_progress_bar_1.value = calc_jar_percent(0)
	honeycomb_texture_progress_bar_2.value = calc_jar_percent(1)
	honeycomb_texture_progress_bar_2.modulate = Color.WHITE if honeycomb_texture_progress_bar_2.value > 0 else Color.TRANSPARENT
	
	honeycomb_texture_progress_bar_3.value = calc_jar_percent(2)
	honeycomb_texture_progress_bar_3.modulate = Color.WHITE if honeycomb_texture_progress_bar_3.value > 0 else Color.TRANSPARENT
	
	honeycomb_texture_progress_bar_4.value = calc_jar_percent(3)
	honeycomb_texture_progress_bar_4.modulate = Color.WHITE if honeycomb_texture_progress_bar_4.value > 0 else Color.TRANSPARENT
	
	honeycomb_texture_progress_bar_5.value = calc_jar_percent(4)
	honeycomb_texture_progress_bar_5.modulate = Color.WHITE if honeycomb_texture_progress_bar_5.value > 0 else Color.TRANSPARENT
	
	honeycomb_texture_progress_bar_6.value = calc_jar_percent(5)
	honeycomb_texture_progress_bar_6.modulate = Color.WHITE if honeycomb_texture_progress_bar_6.value > 0 else Color.TRANSPARENT

	# Update Status:
	if raw_honey_produced >= raw_honey_needed_for_a_jar && raw_honey_produced < raw_honey_needed_for_a_jar*1.93:
		status_label.text = "Honeycomb is ready"
		if player_nearby != null && player_nearby.holding != BeeKeeper.Holding.NOTHING:
			status_label.text += " - Hands full"
	elif raw_honey_produced >= raw_honey_needed_for_a_jar:
		status_label.text = "Honeycombs are ready"
		if player_nearby != null && player_nearby.holding != BeeKeeper.Holding.NOTHING:
			status_label.text += " - Hands full"
	elif pollen_collected < 10:
		status_label.text = "Bees are collecting pollen"
	elif raw_honey_produced < raw_honey_needed_for_a_jar:
		status_label.text = "Bees are making honey, bee patient"
	else:
		status_label.text = "Bees are doing bee things"
		
	
	if player_nearby != null:
		info_panel.show()
		if player_nearby.holding == BeeKeeper.Holding.NOTHING \
		  && raw_honey_produced > raw_honey_needed_for_a_jar:
			action_button.show()
		else:
			action_button.hide()			
	else:
		action_button.hide()
		info_panel.hide()
	
	if Input.is_action_pressed("show_all_stats_key") || mouse_hovering:
		info_panel.show()
		
	
func calc_jar_percent(jar_index: float) -> float:
	return min(100.0,( raw_honey_produced / raw_honey_needed_for_a_jar - jar_index) * 100.0)
	
func _on_interactive_area_2d_body_entered(body: Node2D) -> void:
	if body is BeeKeeper:
		player_nearby = body

func _on_interactive_area_2d_body_exited(body: Node2D) -> void:
	if body is BeeKeeper:
		player_nearby = null

func _on_action_button_pressed() -> void:
	if raw_honey_produced >= raw_honey_needed_for_a_jar:
		# For now always collect high quality honey
		raw_honey_produced -= raw_honey_needed_for_a_jar
		honey_collected.emit()

func _on_honey_production_timer_timeout() -> void:
	# Time for the bee colony to work!
	
	# As we get more and more bees in our colony, 
	# bees produce more and more raw honey at a time.
	var honey_production_iterations = ceili(total_bees / float(bees_needed_to_convert_pollen_to_honey))
	 
	for i in range(honey_production_iterations):
		if pollen_collected > pollen_needed_to_produce_one_raw_honey:
			if raw_honey_produced < max_raw_honey_capacity:
				raw_honey_produced += 1
				pollen_collected -= pollen_needed_to_produce_one_raw_honey

func _on_hive_upkeep_timer_timeout() -> void:
	# Bees die of old age
	total_bees = max(8000, floori(total_bees * 0.997))
	
	# When killing bees, keep a mimimum alive for the purpose of the game jam
	#total_bees = int(total_bees * 0.9) #
	var honey_to_feed_all_the_bees = total_bees * raw_honey_consumption_ratio
	if raw_honey_produced > honey_to_feed_all_the_bees:
		# Feed the bees
		is_starving = false
		raw_honey_produced -= honey_to_feed_all_the_bees
		total_bees = min(max_population, total_bees + bee_growth) # todo make a range
	else:
		# Starving!!
		is_starving = true
		total_bees = max(8000, ceili(total_bees * 0.95))
	
	pass # Replace with function body.

#Jon was here (/snarky)

func _on_bee_spawn_timer_timeout() -> void:
	# Spawn a bee when this hive has spawned less than the max number of bees
	# base on it's bee numbers. X simulated bees yield 1 bee sprite to represnet them
	
	var bee_sprites_belonging_to_this_hive = 0
	var all_bees = get_tree().get_nodes_in_group("bee_group")
	for b in all_bees:
		var bee = b as Bee
		if bee.home_hive == self:
			bee_sprites_belonging_to_this_hive += 1
	
	if  bee_sprites_belonging_to_this_hive < (total_bees/bees_to_sprite_threshold):
		spawn_bee.emit(self)

func _on_mouse_entered() -> void:
	mouse_hovering = true


func _on_mouse_exited() -> void:
	mouse_hovering = false
