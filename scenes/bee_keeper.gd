extends CharacterBody2D
class_name BeeKeeper


enum Holding { NOTHING, HONEY_LOW, HONEY_HIGH, MEAD_LOW, MEAD_HIGH, SMOKER, SODA_CAN }
enum Action { IDLE, WALKING }
const SPEED = 300.0

@export var GoToObj : Node2D #idk why this wasnt working but whatever
@export var player_rig: PlayerAnimations

var target_position : Vector2
var click_position : Vector2
var holding := Holding.NOTHING
var anim_state := Action.IDLE

func _ready():
	GoToObj = get_node("../GoingTowardsThisPoint")
	click_position = position

func _process(_delta: float) -> void:
	%HoneyHighSprite.visible = holding == Holding.HONEY_HIGH
	
	if holding:
		if anim_state == Action.WALKING:
			player_rig.animations.animation = "walking_hold"
		elif anim_state == Action.IDLE:
			player_rig.animations.animation = "idle_hold"
	else:
		if anim_state == Action.WALKING:
			player_rig.animations.animation = "walking"
		elif anim_state == Action.IDLE:
			player_rig.animations.animation = "idle"

func _physics_process(_delta: float) -> void:
	if position.distance_to(click_position) > 3:
		target_position = (click_position - position).normalized()
		velocity = target_position * SPEED
		anim_state = Action.WALKING
		move_and_slide()
	else:
		anim_state = Action.IDLE
		velocity = Vector2.ZERO
		
		
func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("left_click"):
		click_position = get_global_mouse_position()
		GoToObj.global_position = click_position
		
		var test = position.direction_to(click_position)
		print(test)
		
		if test.x < 0:
			scale.x = -1
		elif test.x > 0:
			scale.x = 1


func _on_bee_colony_honey_collected() -> void:
	if holding == Holding.NOTHING:
		holding = Holding.HONEY_HIGH


func _on_workbench_placed() -> void:
	if holding != Holding.NOTHING:
		holding = Holding.NOTHING
		# TODO put the item on the workbench
		
