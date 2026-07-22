extends RigidBody2D
class_name Enemy

@export var SPEED: float = 100.0

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

var player: Player
var last_direction: Vector2 = Vector2.ZERO
var movement_delta: float
# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_tree().get_first_node_in_group("Player")
	nav_agent.velocity_computed.connect(_on_velocity_computed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	# Do not query when the map has never synchronized and is empty.
	if NavigationServer2D.map_get_iteration_id(nav_agent.get_navigation_map()) == 0:
		return

	nav_agent.target_position = player.global_position
	movement_delta = delta * SPEED

	var next_path_position: Vector2 = nav_agent.get_next_path_position()
	var new_velocity: Vector2 = global_position.direction_to(next_path_position) * movement_delta
	if nav_agent.avoidance_enabled:
		nav_agent.set_velocity(new_velocity)
	else:
		_on_velocity_computed(new_velocity)

	last_direction = new_velocity.normalized()


func get_last_direction(): return last_direction

func _on_velocity_computed(safe_velocity: Vector2):
	global_position = global_position.move_toward(global_position + safe_velocity, movement_delta)
