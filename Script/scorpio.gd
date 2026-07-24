extends RigidBody2D
class_name Scorpio

@export var SPEED: float = 100.0
@export var SPIN_SPEED: float = 100.0

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

@onready var visual: Sprite2D = $Visual

@onready var spin_timer: Timer = $SpinTimer
@onready var spin_cooldown: Timer = $SpinCooldown

var player: Player
var last_direction: Vector2 = Vector2.ZERO
var movement_delta: float
var can_move: bool = true

var tween_resume: Tween
var tween: Tween

var spinning: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_tree().get_first_node_in_group("Player")
	nav_agent.velocity_computed.connect(_on_velocity_computed)
	EventBus.player_died.connect(func(): can_move = false)
	EventBus.player_revived.connect(resume)
	spin_cooldown.timeout.connect(func():
		spin_cooldown.stop()
		nav_agent.avoidance_enabled = false
		spinning = true
		spin_timer.start()
	)
	spin_timer.timeout.connect(func():
		spin_timer.stop()
		nav_agent.avoidance_enabled = true
		spinning = false
		rotation = 0
		spin_cooldown.start(randf_range(1, 5))
	)
	spin_cooldown.start(randf_range(1, 5))

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

	if can_move and spinning:
		rotation += SPIN_SPEED * delta
	else:
		look_at(player.global_position)


func get_last_direction(): return last_direction

func _on_velocity_computed(safe_velocity: Vector2):
	if can_move:
		move_and_collide(safe_velocity.normalized() * movement_delta)

func resume():
	if tween_resume: tween_resume.kill()

	tween_resume = create_tween()
	tween_resume.tween_method(func(value: bool): can_move = value, false, true, 1)

func animate_damage():
	nav_agent.avoidance_enabled = true
	spinning = false
	rotation = 0
	can_move = false

	if tween:
			tween.kill()
		
	tween = create_tween()
	tween.tween_property(visual, "visible", false, 0.1)
	tween.chain().tween_property(visual, "visible", true, 0.1)
	tween.set_loops(5)
	tween.finished.connect(func(): can_move = true)
