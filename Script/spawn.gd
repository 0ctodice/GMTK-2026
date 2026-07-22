extends Node2D

@export var enemy_scene: PackedScene
var rng: RandomNumberGenerator

# Called when the node enters the scene tree for the first time.
func _ready():
	rng = RandomNumberGenerator.new()
	_spawn_enemies()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _spawn_enemies():
	var spawn_number: int = rng.randi_range(1, 5)

	for i in range(spawn_number):
		var enemy_instance = enemy_scene.instantiate()
		enemy_instance.global_position = global_position
		get_parent().add_child(enemy_instance)
