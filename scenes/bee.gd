class_name Bee
extends AnimatableBody2D

enum Objective { LEAVE_BEE_HIVE, FORAGING, FOUND_FOOD, GET_FOOD, BEELING_IT_BACK_TO_THE_HIVE, ENTER_BEE_HIVE  }
enum Action { FLYING, IDLE }

@export var threshold_pollen_before_returning_home := 100
@onready var animations: AnimatedSprite2D = %Animations


var heading := 0.0 #180 degrees
var currently_facing_right := true
var foraging_iteration := 0
var foraging_iteration_never_resets := 0
var foraging_with_pollen_iteration := 0
var flower_harvesting_iteration := 0
var nearby_flowers : Array[Flower] = []
var flowers_visited : Array[Flower] = []
var flower_of_interest : Flower = null
var pollen_collected := 0
var home_hive : BeeColony = null
#var bee_transition_type_pattern := bee_transition_type_factory()
var current_objective := Objective.LEAVE_BEE_HIVE
var anim_state = Action.FLYING

var Line : Line2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Line = get_node("Line2D")
	Line.joint_mode = Line2D.LINE_JOINT_ROUND
	Line.set_point_position(0, global_position)
	Line.set_point_position(1, global_position)
	Line.set_point_position(2, global_position)
	Line.set_point_position(3, global_position)
	bee_navigate_generator()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#z_index = int(global_position.y)
	if anim_state == Action.FLYING:
		animations.animation = "flying"
	elif anim_state == Action.IDLE:
		animations.animation = "idle"
	
	if currently_facing_right:
		animations.scale = Vector2(1,1)
	else:
		animations.scale = Vector2(-1,1)
# just cause
func _physics_process(delta: float) -> void:
	Line.global_position = Vector2.ZERO
	Line.set_point_position(0, global_position)
	Line.set_point_position(1, Line.get_point_position(1).lerp(Line.get_point_position(0), 0.05))
	Line.set_point_position(2, Line.get_point_position(2).lerp(Line.get_point_position(1), 0.05))
	Line.set_point_position(3, Line.get_point_position(3).lerp(Line.get_point_position(2), 0.05))

func bee_navigate_generator() -> void:
	# If we're near a flower and need pollen, consider the flower
	for f in nearby_flowers:
		if flower_of_interest == null \
		   && current_objective == Objective.FORAGING \
		   && !f.being_harvested \
		   && f.pollen_available > 0 \
		   && !flowers_visited.has(f):			
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
			foraging_iteration_never_resets = 0
			heading = randf_range(0, PI)
		Objective.FORAGING:
			# Bees wondering around 
			# Picks a vector of length 50,50 to 150,150 that is pointed towards the current heading
			var buzz_path = Vector2(randi_range(50, 150), randi_range(50, 150)) * Vector2.from_angle(heading)
			# Adjust the heading slightly at first, but after a bit, the heading changes. This way the bees
			# do not go in the same direction forever, but they do go in the same direction for a bit
			heading += randf_range(-0.174533 * (foraging_iteration % 10), 0.174533 * (foraging_iteration % 10))
			foraging_iteration += 1
			foraging_iteration_never_resets += 1
			if (foraging_iteration > 100):
				# Keep things from getting too wild
				foraging_iteration = 0
			
			# Used as a safety net so we don't look for more flowers forever before returning home
			if pollen_collected > 0:
				foraging_with_pollen_iteration += 1
				if foraging_with_pollen_iteration > 90:
					current_objective = Objective.BEELING_IT_BACK_TO_THE_HIVE		
			elif foraging_iteration_never_resets > 300:			
				# Fail safe if the bee just gets super lost and never finds a flower, just back home			
				current_objective = Objective.BEELING_IT_BACK_TO_THE_HIVE				
			
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
				flowers_visited.append(flower_of_interest)
				flower_harvesting_iteration = 0
			else:
				current_objective = Objective.FORAGING
				bee_navigate_generator()
		Objective.GET_FOOD:	
			if flower_of_interest != null:
				# The bee will move about the flower's surface while collecting all the pollen from the flower
				if flower_of_interest.pollen_available > 0 && flower_harvesting_iteration < randi_range(3,5) && pollen_collected < threshold_pollen_before_returning_home:
					flower_harvesting_iteration += 1
					# Continue getting pollen
					var pollen_collected_this_step = min(flower_of_interest.pollen_available, randi_range(8,12))
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
					# Collect pollen from multiple flowers before heading back
					# So I can collect a few times from a flower until the bee is filled up
					flower_of_interest.being_harvested = false
					flower_of_interest = null
					
					if pollen_collected >= threshold_pollen_before_returning_home:
						current_objective = Objective.BEELING_IT_BACK_TO_THE_HIVE
					else:
						current_objective = Objective.FORAGING
					bee_navigate_generator()
			else:
				current_objective = Objective.FORAGING
				bee_navigate_generator()
		Objective.BEELING_IT_BACK_TO_THE_HIVE:	
				# buzz our bees to the flower of choice in a nifty way			
				var goal_position = home_hive.get_node("ExitHiveMarker2D").global_position
				if position.distance_to(goal_position) < 300:					
					var new_position = world_clamp(goal_position)
					var tween = get_tree().create_tween()
					tween.tween_property(self, "position", new_position, 3).set_trans(Tween.TRANS_LINEAR )
					current_objective = Objective.ENTER_BEE_HIVE
					set_facing(new_position)
					tween.tween_callback(bee_navigate_generator)
				else:		
					var distance_to_span_this_round = Vector2(100,100)
					var heading_to_bee_hive = position.angle_to_point(goal_position)
					var new_position = world_clamp(position + (distance_to_span_this_round * Vector2.from_angle(heading_to_bee_hive)))
					var tween = get_tree().create_tween()
					tween.tween_property(self, "position", new_position, 1).set_trans(Tween.TRANS_LINEAR )
					set_facing(new_position)
					tween.tween_callback(bee_navigate_generator)
		Objective.ENTER_BEE_HIVE:	
			# Transfer pollen to the hive
			home_hive.pollen_collected += pollen_collected
			queue_free() # =(
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
	
func left_flower(flower: Flower):
	nearby_flowers.erase(flower)

func set_facing(new_position: Vector2) -> void:
	currently_facing_right = new_position.x > position.x

#func bee_transition_type_factory() -> Tween.TransitionType:
	#var randi = randi_range(0, 4)
	#match randi:
		#0: return Tween.TransitionType.TRANS_LINEAR
		#1: return Tween.TransitionType.TRANS_SINE
		#2: return Tween.TransitionType.TRANS_SPRING
		#_: return Tween.TransitionType.TRANS_CIRC
