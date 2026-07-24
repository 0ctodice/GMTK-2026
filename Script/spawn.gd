extends Node2D
class_name Spawn
@export var enemy_scenes: Array[PackedScene]

var rng: RandomNumberGenerator
var tween: Tween
var spawn_number: int = 1
var difficulty_level: int = 1

var can_spawn: bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	rng = RandomNumberGenerator.new()
	var initial_scale = scale
	scale = Vector2.ZERO
	rotation_degrees = randf_range(-45, 45)
	tween = create_tween()

	tween.tween_property(self, "scale", initial_scale, 0.5)
	tween.tween_property(self, "scale", initial_scale, 0.5)
	
	tween.finished.connect(_spawn_enemies)
	EventBus.player_died.connect(func(): can_spawn = false)

func _spawn_enemies():
	if can_spawn:
		for i in range(spawn_number):
			var enemy_instance = choose_enemy_scene().instantiate()
			enemy_instance.global_position = global_position
			get_parent().add_child(enemy_instance)
			
	if tween: tween.kill()
	tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.5)
	tween.finished.connect(queue_free)

func choose_enemy_scene() -> PackedScene:
	if difficulty_level == 4:
		return enemy_scenes[1]
	elif difficulty_level == 5 or difficulty_level == 6:
		return enemy_scenes[randi_range(0, 1)]
	elif difficulty_level == 7:
		return enemy_scenes[2]
	elif difficulty_level > 7:
		return enemy_scenes[randi_range(0, len(enemy_scenes) - 1)]
	else:
		return enemy_scenes[0]

func set_spawn_number(value: int, difficulty: int):
	spawn_number = value
	difficulty_level = difficulty