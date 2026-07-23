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

const MAX_HEALTH: int = 3

var dashing: bool = false
var resurrecting: bool = false
var last_direction: Vector2 = Vector2.ZERO

var can_move: bool = false
var can_dash: bool = false
var can_take_damage: bool = true
var current_health: int = MAX_HEALTH
var initial_position: Vector2

var tween: Tween

func _ready():
	initial_position = position

	dashing_time.timeout.connect(func():
		dashing = false
		if not resurrecting:
			hurt_box_collision_shape.disabled = false
		dashing_time.stop()
		dash_cooldown.start()
	)
	
	dash_cooldown.timeout.connect(func(): can_dash = true)
	EventBus.player_revived.connect(resurrection)
	EventBus.new_level.connect(func(_level_index):
		can_move = true
		can_dash = true
	)
	
	EventBus.door_entered.connect(func(): z_index = -1)
	EventBus.close_door.connect(reset_player)

func _physics_process(delta):
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
	if can_take_damage:
		var enemy_direction = (body as Enemy).get_last_direction()
		var handle_damage = func(): take_damage(enemy_direction)
		can_take_damage = false
		handle_damage.call_deferred()

func take_damage(bounce_direction: Vector2):
	hurt_box_collision_shape.disabled = true
	velocity = bounce_direction * SPEED * DASH_FACTOR / 2
	current_health -= 1
	if current_health == 0:
		velocity = Vector2.ZERO
		can_move = false
		animate_damage(5, EventBus.player_died.emit)
	elif current_health > 0:
		animate_damage(5, reenable_collision)

	EventBus.took_damage.emit()

func animate_damage(loops: int, action: Callable):
	if tween:
			tween.kill()
		
	tween = create_tween()
	tween.tween_property(visual, "visible", false, 0.1)
	tween.chain().tween_property(visual, "visible", true, 0.1)
	tween.set_loops(loops)
	tween.finished.connect(action)

func reenable_collision():
	hurt_box_collision_shape.disabled = false
	can_take_damage = true
	if resurrecting:
		resurrecting = false

func resurrection():
	can_move = true
	can_dash = true
	current_health = MAX_HEALTH
	resurrecting = true
	animate_damage(10, reenable_collision)


func reset_player():
	z_index = 0
	can_move = false
	can_dash = false
	velocity = Vector2.ZERO
	last_direction = Vector2.ZERO
	position = initial_position