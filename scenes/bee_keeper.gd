class_name BeeKeeper
extends CharacterBody2D

enum Holding { NOTHING, HONEY_LOW, HONEY_HIGH, MEAD_LOW, MEAD_HIGH, SMOKER, SODA_CAN, HONEYCOMB_HIGH, BEESWAX }
enum Action { IDLE, WALKING }
const SPEED = 300.0

@export var GoToObj : Node2D #idk why this wasnt working but whatever
@export var player_rig: PlayerAnimations

@onready var player_animations: PlayerAnimations = %PlayerAnimations
@onready var honey_high_sprite: Sprite2D = %HoneyHighSprite
@onready var beeswax_high_sprite: Sprite2D = %BeeswaxHighSprite
@onready var honeycomb_high_sprite: Sprite2D = %HoneycombHighSprite


var target_position : Vector2
var click_position : Vector2
var holding := Holding.NOTHING
var anim_state := Action.IDLE
var player_facing_right : bool = true
var direction_facing
var player_base_scale: Vector2

func _ready():
	GoToObj = get_node("../GoingTowardsThisPoint")
	click_position = position
	player_base_scale = scale
	direction_facing = player_base_scale.x


func _process(_delta: float) -> void:
	honey_high_sprite.visible = holding == Holding.HONEY_HIGH
	beeswax_high_sprite.visible = holding == Holding.BEESWAX
	honeycomb_high_sprite.visible = holding == Holding.HONEYCOMB_HIGH
	
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

		if GoToObj.global_position.x > position.x && scale != Vector2.ONE:
			scale = Vector2(1, 1)
			rotation_degrees = 0
		elif GoToObj.global_position.x < position.x && scale == Vector2.ONE:
			scale = Vector2(1, -1)
			rotation_degrees = 180


func _on_bee_colony_honey_collected() -> void:
	if holding == Holding.NOTHING:
		holding = Holding.HONEYCOMB_HIGH


func _on_workbench_placed() -> void:
	if holding != Holding.NOTHING:
		holding = Holding.NOTHING		


func _on_sell_box_placed() -> void:
	if holding != Holding.NOTHING:
		holding = Holding.NOTHING
