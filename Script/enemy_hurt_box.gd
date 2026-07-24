extends Area2D

@export var LIFE_POINTS: int = 50

func take_damage(damage: int):
	LIFE_POINTS -= damage
	if LIFE_POINTS <= 0:
		get_parent().queue_free()
		EventBus.enemy_died.emit()
	else:
		get_parent().animate_damage()


func _input(_event):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		take_damage(10)