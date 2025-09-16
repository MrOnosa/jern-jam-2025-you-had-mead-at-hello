extends CharacterBody2D
class_name BeeKeeper


const SPEED = 300.0
var target_position : Vector2
var click_position : Vector2

func _ready():
	click_position = position

func _physics_process(delta: float) -> void:
	
	if Input.is_action_just_pressed("left_click"):
		click_position = get_global_mouse_position()
		
	if position.distance_to(click_position) > 3:
		target_position = (click_position - position).normalized()
		velocity = target_position * SPEED
		move_and_slide()
	
	# Add the gravity.
	## Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
#
	## Get the input direction and handle the movement/deceleration.
	## As good practice, you should replace UI actions with custom gameplay actions.
	#var direction := Input.get_axis("ui_left", "ui_right")
	#if direction:
		#velocity.x = direction * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
