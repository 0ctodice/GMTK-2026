extends RigidBody2D

@export var SPEED: float = 100.0

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

var player: Player
var initial_position: Vector2 = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_tree().get_first_node_in_group("Player")
	initial_position = global_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	nav_agent.target_position = player.global_position
	global_position = global_position.move_toward(nav_agent.get_next_path_position(), delta * SPEED)
