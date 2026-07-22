extends Node2D

@export var spawn_scene: PackedScene
@export var enemy_sprite_size: Vector2 = Vector2.ONE * 16
@onready var spawn_timer: Timer = $SpawnTimer

var rng: RandomNumberGenerator
var screen_size: Vector2
# Called when the node enters the scene tree for the first time.
func _ready():
	rng = RandomNumberGenerator.new()
	screen_size = get_viewport().get_visible_rect().size
	spawn_timer.timeout.connect(_create_spawners)

func _create_spawners():
	var spawn_number: int = rng.randi_range(1, 3)

	for i in range(spawn_number):
		var rand_x = rng.randf_range(enemy_sprite_size.x, screen_size.x - enemy_sprite_size.x)
		var rand_y = rng.randf_range(enemy_sprite_size.y, screen_size.y - enemy_sprite_size.y)
		
		var spawn_instance = spawn_scene.instantiate()
		spawn_instance.global_position = Vector2(rand_x, rand_y)
		add_child(spawn_instance)

	spawn_timer.start(rng.randf_range(1, 5))
