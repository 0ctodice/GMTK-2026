extends RigidBody2D
class_name Beetle

@export var SPEED: float = 100.0
@export var DASH_FACTOR: float = 2.0

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

@onready var dash_timer: Timer = $DashTimer
@onready var dash_cooldown: Timer = $DashCooldown

@onready var visual: Sprite2D = $Visual
@onready var visual_dashing: Sprite2D = $VisualDashing
@onready var shadow_dashing: Sprite2D = $ShadowDashing

var player: Player
var last_direction: Vector2 = Vector2.ZERO
var movement_delta: float
var can_move: bool = true

var tween_resume: Tween

var tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_tree().get_first_node_in_group("Player")
	nav_agent.velocity_computed.connect(_on_velocity_computed)
	EventBus.player_died.connect(func(): can_move = false)
	EventBus.player_revived.connect(resume)
	dash_cooldown.timeout.connect(func():
		nav_agent.avoidance_enabled = false
		dash_timer.start()
		visual_dashing.visible = true
		shadow_dashing.visible = true
	)
	dash_timer.timeout.connect(func():
		nav_agent.avoidance_enabled = true
		visual_dashing.visible = false
		shadow_dashing.visible = false
	)
	dash_cooldown.start(randf_range(1, 5))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	look_at(player.global_position)
	# Do not query when the map has never synchronized and is empty.
	if NavigationServer2D.map_get_iteration_id(nav_agent.get_navigation_map()) == 0:
		return

	nav_agent.target_position = player.global_position
	movement_delta = delta * SPEED

	if not nav_agent.avoidance_enabled:
		movement_delta *= DASH_FACTOR

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

func animate_damage():
	nav_agent.avoidance_enabled = true
	visual_dashing.visible = false
	shadow_dashing.visible = false

	can_move = false

	if tween:
			tween.kill()
		
	tween = create_tween()
	tween.tween_property(visual, "visible", false, 0.1)
	tween.chain().tween_property(visual, "visible", true, 0.1)
	tween.set_loops(5)
	tween.finished.connect(func(): can_move = true)
