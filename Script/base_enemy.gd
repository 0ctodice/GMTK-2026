extends RigidBody2D
class_name Enemy

@export var SPEED: float = 100.0

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

var player: Player
var last_direction: Vector2 = Vector2.ZERO
var movement_delta: float
var can_move: bool = true

var tween_resume: Tween

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_tree().get_first_node_in_group("Player")
	nav_agent.velocity_computed.connect(_on_velocity_computed)
	EventBus.player_died.connect(func(): can_move = false)
	EventBus.player_revived.connect(resume)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
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
	if can_move:
		move_and_collide(safe_velocity.normalized() * movement_delta)

func resume():
	if tween_resume: tween_resume.kill()

	tween_resume = create_tween()
	tween_resume.tween_method(func(value: bool): can_move = value, false, true, 1)

func _input(_event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_T):
		EventBus.enemy_died.emit()
		queue_free()