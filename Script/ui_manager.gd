extends Control

@onready var color_rect: ColorRect = $ColorRect
@onready var strive: Label = $Strive
@onready var remaining: Label = $Remaining

var tween: Tween

var strive_remaining: int = 9
var player_died: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	EventBus.player_died.connect(transition_to_ui)

	color_rect.modulate = Color.TRANSPARENT
	strive.modulate = Color.TRANSPARENT
	remaining.modulate = Color.TRANSPARENT


# Called every frame. 'delta' is the elapsed time since the previous frame.
func transition_to_ui():
	player_died = true
	strive_remaining -= 1
	if tween: tween.kill()

	tween = create_tween()

	tween.tween_property(color_rect, "modulate", Color.WHITE, 0.5)
	tween.tween_property(color_rect, "modulate", Color.WHITE, 0.25)
	tween.chain().tween_property(strive, "modulate", Color.WHITE, 0.5)
	tween.chain().tween_property(strive, "text", str(strive_remaining), 0.5)
	tween.chain().tween_property(strive, "text", str(strive_remaining), 0.5)
	tween.chain().tween_property(remaining, "modulate", Color.WHITE, 0.25)
	tween.finished.connect(func(): strive.text = str(strive_remaining))

	if strive_remaining > 0:
		transition_to_shop()
	else:
		transition_to_game_over()

func transition_to_shop():
	pass

func transition_to_game_over():
	pass

func transition_to_game():
	if tween: tween.kill()

	tween = create_tween()

	tween.tween_property(color_rect, "modulate", Color.TRANSPARENT, 0.5)
	tween.parallel().tween_property(strive, "modulate", Color.TRANSPARENT, 0.5)
	tween.parallel().tween_property(remaining, "modulate", Color.TRANSPARENT, 0.25)
	tween.finished.connect(EventBus.player_revived.emit)

	player_died = false

func _input(_event):
	if player_died and Input.is_action_just_pressed("dash"): transition_to_game()
