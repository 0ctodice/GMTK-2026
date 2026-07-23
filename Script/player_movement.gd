extends CharacterBody2D
class_name Player

@export var SPEED: float = 150.0
@export var ACCELERATION: float = 2.0
@export var FRICTION: float = 4.0
@export var DASH_FACTOR: float = 2.0

@onready var dash_cooldown: Timer = $DashCooldown
@onready var dashing_time: Timer = $DashingTime
@onready var hurt_box_collision_shape: CollisionShape2D = $HurtBox/CollisionShape2D
@onready var visual: Sprite2D = $Sprite2D

var dashing: bool = false
var can_dash: bool = true
var last_direction: Vector2 = Vector2.ZERO

var tween: Tween
var can_move: bool = true

const MAX_HEALTH: int = 3
var current_health: int = MAX_HEALTH

func _ready():
	dashing_time.timeout.connect(func():
		dashing = false
		hurt_box_collision_shape.disabled = false
		dashing_time.stop()
		dash_cooldown.start()
	)
	
	dash_cooldown.timeout.connect(func(): can_dash = true)
	EventBus.player_died.connect(func(): can_move = false)
	

func _physics_process(delta):
	print(current_health)
	if not can_move:
		return
		
	if not dashing:
		last_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()
		velocity = lerp(velocity, last_direction * SPEED, delta * (FRICTION if last_direction == Vector2.ZERO else ACCELERATION))
	else:
		velocity = lerp(velocity, last_direction * SPEED * DASH_FACTOR, delta * ACCELERATION * DASH_FACTOR)
		
	move_and_slide()

func _input(_event):
	if can_move and can_dash and Input.is_action_just_pressed("dash"):
		dashing = true
		can_dash = false
		hurt_box_collision_shape.disabled = true
		dashing_time.start()

func _on_hurt_box_body_entered(body: Node2D):
	var enemy_direction = (body as Enemy).get_last_direction()
	var handle_damage = func(): take_damage(enemy_direction)
	handle_damage.call_deferred()

func take_damage(bounce_direction: Vector2):
	hurt_box_collision_shape.disabled = true
	velocity = bounce_direction * SPEED * DASH_FACTOR / 2
	current_health -= 1
	EventBus.screen_shake.emit()
	if current_health == 0:
		EventBus.player_died.emit()
	elif current_health > 0:
		if tween:
			tween.kill()
		
		tween = create_tween()
		tween.tween_property(visual, "visible", false, 0.1)
		tween.chain().tween_property(visual, "visible", true, 0.1)
		tween.set_loops(5)
		tween.finished.connect(func(): hurt_box_collision_shape.disabled = false)
