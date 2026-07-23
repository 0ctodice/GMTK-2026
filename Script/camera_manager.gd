extends Camera2D

@export var duration: float = 1.0
@export var strength: float = 50.0

var tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready():
	EventBus.screen_shake.connect(shake)


func shake():
	var base_offset: Vector2 = offset
	if tween: tween.kill()
	tween = create_tween()
	tween.tween_method(func(delay: float):
		var movement = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * strength * delay
		offset = base_offset + movement, 1.0, 0.0, duration)