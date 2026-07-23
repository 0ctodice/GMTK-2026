extends Node2D
class_name Spawn
@export var enemy_scene: PackedScene

@onready var sprite: Sprite2D = $Sprite2D

var rng: RandomNumberGenerator
var tween: Tween
var spawn_number: int = 3

var can_spawn: bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	rng = RandomNumberGenerator.new()
	var initial_scale = sprite.scale
	sprite.scale = Vector2.ZERO
	tween = create_tween()

	tween.tween_property(sprite, "scale", initial_scale, 0.5)
	tween.tween_property(sprite, "scale", initial_scale, 0.5)
	
	tween.finished.connect(_spawn_enemies)
	EventBus.player_died.connect(func(): can_spawn = false)

func _spawn_enemies():
	if can_spawn:
		for i in range(spawn_number):
			var enemy_instance = enemy_scene.instantiate()
			enemy_instance.global_position = global_position
			get_parent().add_child(enemy_instance)
			
	if tween:
		tween.kill()

	tween = create_tween()

	tween.tween_property(sprite, "scale", Vector2.ZERO, 0.5)

	tween.finished.connect(queue_free)

func set_spawn_number(value: int): spawn_number = value