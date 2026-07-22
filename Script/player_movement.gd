extends CharacterBody2D
class_name Player

@export var SPEED: float = 150.0
@export var ACCELERATION: float = 2.0
@export var FRICTION: float = 4.0
@export var DASH_FACTOR: float = 2.0

@onready var dash_cooldown: Timer = $DashCooldown
@onready var dashing_time: Timer = $DashingTime
@onready var hurt_box_collision_shape: CollisionShape2D = $HurtBox/CollisionShape2D
@onready var hurt_box_timer: Timer = $HurtBox/Timer

var dashing: bool = false
var can_dash: bool = true
var last_direction: Vector2 = Vector2.ZERO

func _ready():
	dashing_time.timeout.connect(func():
		dashing = false
		hurt_box_collision_shape.disabled = false
		dashing_time.stop()
		dash_cooldown.start()
	)
	
	dash_cooldown.timeout.connect(func(): can_dash = true)
	hurt_box_timer.timeout.connect(func(): hurt_box_collision_shape.disabled = false)
	

func _physics_process(delta):
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
		hurt_box_collision_shape.disabled = true
		dashing_time.start()

func _on_hurt_box_body_entered(body: Node2D):
	var enemy_direction = (body as Enemy).get_last_direction()
	print(enemy_direction)
	hurt_box_collision_shape.set_deferred("disabled", true)
	hurt_box_timer.start()
	velocity = (velocity + enemy_direction).normalized() * DASH_FACTOR * SPEED