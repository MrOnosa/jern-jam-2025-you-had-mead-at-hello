extends CharacterBody2D
class_name BeeKeeper


enum Holding { NOTHING, HONEY_LOW, HONEY_HIGH, MEAD_LOW, MEAD_HIGH, SMOKER, SODA_CAN }
const SPEED = 300.0

@export var GoToObj : Node2D #idk why this wasnt working but whatever

var target_position : Vector2
var click_position : Vector2
var holding := Holding.NOTHING

func _ready():
	GoToObj = get_node("../GoingTowardsThisPoint")
	click_position = position

func _process(_delta: float) -> void:
	%HoneyHighSprite.visible = holding == Holding.HONEY_HIGH

func _physics_process(_delta: float) -> void:
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
		
func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("left_click"):
		click_position = get_global_mouse_position()
		GoToObj.global_position = click_position


func _on_bee_colony_honey_collected() -> void:
	if holding == Holding.NOTHING:
		holding = Holding.HONEY_HIGH


func _on_workbench_placed() -> void:
	if holding != Holding.NOTHING:
		holding = Holding.NOTHING
		# TODO put the item on the workbench
		
