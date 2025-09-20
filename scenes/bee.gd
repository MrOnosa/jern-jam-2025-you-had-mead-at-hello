extends AnimatableBody2D
class_name Bee

enum Objective { LEAVE_BEE_HIVE, FORAGING, FOUND_FOOD, GET_FOOD, BEELING_IT_BACK_TO_THE_HIVE, ENTER_BEE_HIVE  }
var heading := 0.0 #180 degrees
var currently_faceing_right := true
var foraging_iteration := 0
var nearby_flowers : Array[Flower] = []
var flower_of_interest : Flower = null
var pollen_collected := 0
var home_hive : BeeColony = null
#var bee_transition_type_pattern := bee_transition_type_factory()
var current_objective := Objective.LEAVE_BEE_HIVE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	bee_navigate_generator()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if currently_faceing_right:
		$AnimatedSprite2D.scale = Vector2(1,1)
	else:
		$AnimatedSprite2D.scale = Vector2(-1,1)

func bee_navigate_generator() -> void:
	# If we're near a flower and need pollen, consider the flower
	for f in nearby_flowers:
		if flower_of_interest == null && current_objective == Objective.FORAGING && !f.being_harvested && f.pollen_available > 0:
			f.being_harvested = true
			current_objective = Objective.FOUND_FOOD
			flower_of_interest = f
	
	# Now control how the bee will move using short tweens. This will use the callback to here after each movement
	match current_objective:
		Objective.LEAVE_BEE_HIVE:
			scale = Vector2.ZERO
			var tween = get_tree().create_tween()
			#tween.tween_property(self, "scale", Vector2.ONE, 1).set_trans(Tween.TRANS_LINEAR)
			var new_position = world_clamp(position + Vector2(randi_range(-10, 10), randi_range(30, 80)))
			tween.tween_property(self, "position", new_position, randf_range(0.5, 1.5)).set_trans(Tween.TRANS_SINE )
			set_facing(new_position)
			tween.tween_callback(bee_navigate_generator)
			current_objective = Objective.FORAGING
			foraging_iteration = 0
			heading = randf_range(0, PI)
		Objective.FORAGING:
			# Bees wondering around 
			# Picks a vector of length 50,50 to 150,150 that is pointed towards the current heading
			var buzz_path = Vector2(randi_range(50, 150), randi_range(50, 150)) * Vector2.from_angle(heading)
			# Adjust the heading slightly at first, but after a bit, the heading changes. This way the bees
			# do not go in the same direction forever, but they do go in the same direction for a bit
			heading += randf_range(-0.174533 * (foraging_iteration % 10), 0.174533 * (foraging_iteration % 10))
			foraging_iteration += 1
			if (foraging_iteration > 100):
				# Keep things from getting too wild
				foraging_iteration = 0
			
			var tween = get_tree().create_tween()
			var new_position = world_clamp(position + buzz_path)
			tween.tween_property(self, "position", new_position, randf_range(0.7, 1.2)).set_trans(Tween.TRANS_SINE )
			set_facing(new_position)
			tween.tween_callback(bee_navigate_generator)			
		Objective.FOUND_FOOD:
			if flower_of_interest != null:
				# buzz our bees to the flower of choice in a nifty way			
				var new_position = world_clamp(flower_of_interest.get_node("BeeMarker2D").global_position)
				var tween = get_tree().create_tween()
				tween.tween_property(self, "position", new_position, 3).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE )
				current_objective = Objective.GET_FOOD
				set_facing(new_position)
				tween.tween_callback(bee_navigate_generator)			
			else:
				current_objective = Objective.FORAGING
				bee_navigate_generator()
		Objective.GET_FOOD:	
			if flower_of_interest != null:
				# The bee will move about the flower's surface while collecting all the pollen from the flower
				if flower_of_interest.pollen_available > 0:
					# Continue getting pollen
					var pollen_collected_this_step = min(flower_of_interest.pollen_available, randi_range(8,102))
					flower_of_interest.pollen_available -= pollen_collected_this_step
					pollen_collected += pollen_collected_this_step
					
					var flower_bee_marker = flower_of_interest.get_node("BeeMarker2D").global_position
					var collision_shape_2d = flower_of_interest.get_node("CollectionArea2D/CollectionShape2D") as CollisionShape2D
					
					var rect : Rect2 = collision_shape_2d.shape.get_rect()
					var x = randf_range(rect.position.x, rect.position.x+rect.size.x)
					var y = randf_range(rect.position.y, rect.position.y+rect.size.y)
					var new_position = world_clamp(flower_bee_marker + Vector2(x,y)) 
					
					var tween = get_tree().create_tween()
					tween.tween_property(self, "position", new_position, 3).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE )
					set_facing(new_position)
					tween.tween_callback(bee_navigate_generator)
				else:
					#TODO: Collect pollen from multiple flowers before heading back
					# So I can collect a few times from a flower until the bee is filled up
					# bees could keep a list of flowers theyve visited in thier trip to avoid
					# going to the same flower over and over again
					# and having a safty timeout so if there are no more flowers
					# and they have pollen, they head back home anyway
					flower_of_interest.being_harvested = false
					flower_of_interest = null
					current_objective = Objective.BEELING_IT_BACK_TO_THE_HIVE
					bee_navigate_generator()
			else:
				current_objective = Objective.FORAGING
				bee_navigate_generator()
		Objective.BEELING_IT_BACK_TO_THE_HIVE:	
				# buzz our bees to the flower of choice in a nifty way			
				var new_position = world_clamp(home_hive.get_node("ExitHiveMarker2D").global_position)
				var tween = get_tree().create_tween()
				#fix so we go in spurts
				tween.tween_property(self, "position", new_position, 3).set_trans(Tween.TRANS_LINEAR )
				current_objective = Objective.ENTER_BEE_HIVE
				set_facing(new_position)
				tween.tween_callback(bee_navigate_generator)			
		_:	
			var subtween_spin = create_tween()
			subtween_spin.tween_property(self, "rotation_degrees", 45.0, randf_range(0.5, 1.5)).set_trans(Tween.TRANS_SINE ) 
			subtween_spin.tween_property(self, "rotation_degrees", 0.0, randf_range(0.5, 1.5)).set_trans(Tween.TRANS_SINE )		
			
			var tween = get_tree().create_tween()
			#tween.tween_property(self, "position", world_clamp(position + Vector2(randi_range(-30, 30), randi_range(-30, 30))), randf_range(0.5, 1.5)).set_trans(Tween.TRANS_SINE )
			tween.tween_subtween(subtween_spin)
			#tween.tween_property(self, "position", world_clamp(position + Vector2(randi_range(-300, 300), randi_range(-300, 300))), randf_range(0.5, 1.5)).set_trans(Tween.TRANS_SINE )
			tween.tween_callback(bee_navigate_generator)
	
func world_clamp(vector: Vector2) -> Vector2:
	return Vector2(clamp(vector.x, 0, 13000 * .3), clamp(vector.y, 0, 8000 * .3))

func notice_flower(flower: Flower):
	nearby_flowers.append(flower)
	print(" notices flower ",nearby_flowers )
	
func left_flower(flower: Flower):
	nearby_flowers.erase(flower)
	print("=( flower wasn't good enough ", nearby_flowers)

func set_facing(new_position: Vector2) -> void:
	currently_faceing_right = new_position.x > position.x

#func bee_transition_type_factory() -> Tween.TransitionType:
	#var randi = randi_range(0, 4)
	#match randi:
		#0: return Tween.TransitionType.TRANS_LINEAR
		#1: return Tween.TransitionType.TRANS_SINE
		#2: return Tween.TransitionType.TRANS_SPRING
		#_: return Tween.TransitionType.TRANS_CIRC
