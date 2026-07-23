extends Area2D

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var door: Sprite2D = $Door
@onready var particles_left: CPUParticles2D = $ParticlesLeft
@onready var particles_right: CPUParticles2D = $ParticlesRight

var tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready():
	EventBus.level_finished.connect(open_door)
	EventBus.close_door.connect(close_door)

func open_door():
	EventBus.screen_shake.emit()
	if tween: tween.kill()

	particles_left.emitting = true
	particles_right.emitting = true

	tween = create_tween()
	tween.tween_property(door, "position", door.position, 1)
	tween.tween_property(door, "position", door.position + Vector2.UP * 62, 1)
	tween.finished.connect(func(): collision_shape.disabled = false)

func close_door():
	collision_shape.set_deferred("disabled", true)
	door.set_deferred("position", door.position + Vector2.DOWN * 62)

func _on_body_entered(_body: Node2D):
	EventBus.door_entered.emit.call_deferred()
