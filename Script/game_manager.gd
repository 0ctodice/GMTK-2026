extends Node2D

@export var spawn_scene: PackedScene
@export var enemy_sprite_size: Vector2 = Vector2.ONE * 16
@onready var spawn_timer: Timer = $SpawnTimer

var rng: RandomNumberGenerator
var screen_size: Vector2

var max_spawners_number: int
var total_spawners: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	rng = RandomNumberGenerator.new()
	screen_size = get_viewport().get_visible_rect().size
	spawn_timer.timeout.connect(_create_spawners)
	max_spawners_number = rng.randi_range(5, 12)

func _create_spawners():
	spawn_timer.stop()
	var spawner_number: int = rng.randi_range(1, 3)

	for i in range(spawner_number):
		var rand_x = rng.randf_range(enemy_sprite_size.x, screen_size.x - enemy_sprite_size.x)
		var rand_y = rng.randf_range(enemy_sprite_size.y, screen_size.y - enemy_sprite_size.y)
		
		var spawn_instance = spawn_scene.instantiate()
		spawn_instance.global_position = Vector2(rand_x, rand_y)
		add_child(spawn_instance)

	total_spawners += spawner_number
	if total_spawners < max_spawners_number:
		spawn_timer.start(rng.randf_range(1, 5))
