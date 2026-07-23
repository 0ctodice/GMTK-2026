extends Node2D

var ankhs = []

var life_point: int = 3

var tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready():
	ankhs = [$Ankh1, $Ankh2, $Ankh3]
	EventBus.took_damage.connect(update_life_points)
	EventBus.player_revived.connect(reset_life_points)

func reset_life_points():
	life_point = 3
	for i in range(3):
		ankhs[i].modulate = Color.hex(0x9eaf79ff)

func update_life_points():
	life_point -= 1
	if tween: tween.kill()
	tween = create_tween()
	tween.tween_property(ankhs[life_point], "modulate", Color.TRANSPARENT, 0.5)