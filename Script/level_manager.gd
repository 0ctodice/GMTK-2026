extends Node2D

@export var spawn_scene: PackedScene
@export var enemy_sprite_size: Vector2 = Vector2.ONE * 16

@onready var spawn_timer: Timer = $SpawnTimer
@onready var top_left_spawn_zone_point: Node2D = $TopLeft
@onready var bottom_right_spawn_zone_point: Node2D = $BottomRight

var max_spawners_number: int
var total_spawners: int = 0
var total_enemies_alive: int = 0

var can_spawn: bool = false
var finished_spawning: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_timer.timeout.connect(_create_spawners)
	EventBus.player_died.connect(func(): can_spawn = false)
	EventBus.enemies_spawned.connect(func(new_enemies): total_enemies_alive += new_enemies)
	EventBus.enemy_died.connect(_on_enemy_died)
	EventBus.new_level.connect(func(level_index):
		if level_index < 12:
			set_level()
			can_spawn = true
			spawn_timer.start(randf_range(1, 5))
	)

func _create_spawners():
	spawn_timer.stop()
	if can_spawn:
		var spawner_number: int = randi_range(1, 3)

		for i in range(spawner_number):
			var rand_x = randf_range(
				top_left_spawn_zone_point.global_position.x + enemy_sprite_size.x,
				bottom_right_spawn_zone_point.global_position.x - enemy_sprite_size.x
			)

			var rand_y = randf_range(
				top_left_spawn_zone_point.global_position.y + enemy_sprite_size.y,
				bottom_right_spawn_zone_point.global_position.y - enemy_sprite_size.y
			)
			
			var spawn_instance = spawn_scene.instantiate()
			spawn_instance.global_position = Vector2(rand_x, rand_y)
			add_child(spawn_instance)

		total_spawners += spawner_number
		if total_spawners < max_spawners_number:
			spawn_timer.start(randf_range(1, 5))
		else:
			finished_spawning = true

func _on_enemy_died():
	total_enemies_alive -= 1
	if total_enemies_alive == 0 and finished_spawning:
		set_level()
		EventBus.level_finished.emit()

func set_level():
	total_spawners = 0
	finished_spawning = false
	max_spawners_number = randi_range(5, 12)