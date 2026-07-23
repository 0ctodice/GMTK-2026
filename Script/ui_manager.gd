extends Control

@onready var color_rect: ColorRect = $ColorRect
@onready var strive: Label = $StriveSection/Strive
@onready var remaining: Label = $StriveSection/Remaining

@onready var failed: Label = $GameOverSection/Failed
@onready var sent: Label = $GameOverSection/Sent
@onready var limbo: Label = $GameOverSection/Limbo
@onready var retry: Button = $GameOverSection/Retry

var tween: Tween

var strive_remaining: int = 1

enum STATES {
	IN_GAME,
	IN_SHOP,
	IN_GAME_OVER
}

var state: STATES = STATES.IN_GAME

# Called when the node enters the scene tree for the first time.
func _ready():
	EventBus.player_died.connect(transition_to_ui)

	strive.text = str(strive_remaining)
	color_rect.modulate = Color.TRANSPARENT
	strive.modulate = Color.TRANSPARENT
	remaining.modulate = Color.TRANSPARENT

	failed.modulate = Color.TRANSPARENT
	sent.modulate = Color.TRANSPARENT
	limbo.modulate = Color.TRANSPARENT

	retry.disabled = true
	retry.modulate = Color.TRANSPARENT


# Called every frame. 'delta' is the elapsed time since the previous frame.
func transition_to_ui():
	strive_remaining -= 1
	if tween: tween.kill()

	tween = create_tween()

	tween.tween_property(color_rect, "modulate", Color.WHITE, 0.5)
	tween.tween_property(color_rect, "modulate", Color.WHITE, 0.25)
	tween.chain().tween_property(strive, "modulate", Color.WHITE, 0.5)
	tween.chain().tween_property(strive, "text", str(strive_remaining), 0.5)
	tween.chain().tween_property(strive, "text", str(strive_remaining), 0.5)
	tween.chain().tween_property(remaining, "modulate", Color.WHITE, 0.5)
	tween.finished.connect(func():
		strive.text = str(strive_remaining)
		if strive_remaining > 0:
			transition_to_shop()
		else:
			transition_to_game_over()
	)

func transition_to_shop():
	state = STATES.IN_SHOP

func transition_to_game_over():
	state = STATES.IN_GAME_OVER
	retry.disabled = false

	if tween: tween.kill()

	tween = create_tween()
	
	tween.parallel().tween_property(strive, "modulate", Color.TRANSPARENT, 0.5)
	tween.parallel().tween_property(remaining, "modulate", Color.TRANSPARENT, 0.5)
	tween.parallel().tween_property(remaining, "modulate", Color.TRANSPARENT, 1)
	tween.chain().tween_property(failed, "modulate", Color.WHITE, 0.5)
	tween.chain().tween_property(failed, "modulate", Color.WHITE, 0.5)
	tween.chain().tween_property(sent, "modulate", Color.WHITE, 0.25)
	tween.chain().tween_property(sent, "modulate", Color.WHITE, 1)
	tween.chain().tween_property(limbo, "modulate", Color.hex(0xC43737ff), 0.75)
	tween.chain().tween_property(limbo, "modulate", Color.hex(0xC43737ff), 0.25)
	tween.chain().tween_property(retry, "modulate", Color.WHITE, 0.5)

func transition_to_game():
	state = STATES.IN_GAME
	if tween: tween.kill()

	tween = create_tween()

	tween.tween_property(color_rect, "modulate", Color.TRANSPARENT, 0.5)
	tween.parallel().tween_property(strive, "modulate", Color.TRANSPARENT, 0.5)
	tween.parallel().tween_property(remaining, "modulate", Color.TRANSPARENT, 0.25)
	tween.finished.connect(EventBus.player_revived.emit)

func _input(_event):
	if state == STATES.IN_SHOP and Input.is_action_just_pressed("dash"): transition_to_game()


func _on_retry_pressed():
	get_tree().reload_current_scene()
