extends Camera2D

var Target : Node2D
var Player : Node2D

func _ready():
	Target = get_node("../GoingTowardsThisPoint")
	Player = get_node("../BeeKeeper")
	
func _physics_process(_delta: float) -> void:
	position = position.lerp((Target.position + Player.position) / 2, 0.1)
