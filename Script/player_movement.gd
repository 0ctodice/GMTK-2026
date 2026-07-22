extends CharacterBody2D

@export var SPEED: float = 150.0
@export var ACCELERATION: float = 2.0
@export var FRICTION: float = 4.0
@export var DASH_FACTOR: float = 2.0

@onready var dash_cooldown: Timer = $DashCooldown
@onready var dashing_time: Timer = $DashingTime

var dashing: bool = false
var can_dash: bool = true
var last_direction: Vector2 = Vector2.ZERO

func _ready():
	dashing_time.timeout.connect(func():
		dashing = false
		dashing_time.stop()
		dash_cooldown.start()
	)
	dash_cooldown.timeout.connect(func(): can_dash = true)

func _physics_process(delta):
	print(can_dash)
	if not dashing:
		last_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()
		velocity = lerp(velocity, last_direction * SPEED, delta * (FRICTION if last_direction == Vector2.ZERO else ACCELERATION))
	else:
		velocity = lerp(velocity, last_direction * SPEED * DASH_FACTOR, delta * ACCELERATION * DASH_FACTOR)
		
	move_and_slide()

func _input(_event):
	if can_dash and Input.is_action_just_pressed("dash"):
		dashing = true
		can_dash = false
		dashing_time.start()
