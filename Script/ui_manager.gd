extends Control

@onready var color_rect: ColorRect = $ColorRect
@onready var strive: Label = $StriveSection/Strive
@onready var remaining: Label = $StriveSection/Remaining

@onready var door_number: Label = $DoorSection/DoorNumber
@onready var door_name: Label = $DoorSection/DoorName

@onready var failed: Label = $GameOverSection/Failed
@onready var sent: Label = $GameOverSection/Sent
@onready var limbo: Label = $GameOverSection/Limbo
@onready var retry: Button = $GameOverSection/Retry

enum STATES {
	IN_GAME,
	ENTERING_DOOR,
	IN_SHOP,
	IN_GAME_OVER
}

const DOORS = [
	"ENTERING THE DUAT",
	"TRIALS OF THE DEAD",
	"GUARDIANS OF THE PASSAGE",
	"THE RIVER OF THE UNDERWORLD",
	"THE CHAMBER OF FIRE",
	"THE SERPENT'S LAIR",
	"THE JUDGMENT HALL",
	"TRANSFORMATION AND RENEWAL",
	"THE STARRY ABYSS",
	"THE HIDDEN KNOWLEDGE OF OSIRIS",
	"REACHING THE ENTERNAL FIEDS",
	"FINAL ASCENSION"
]
var tween: Tween
var state: STATES = STATES.ENTERING_DOOR
var strive_remaining: int = 1
var current_level: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	EventBus.player_died.connect(transition_to_ui)
	EventBus.door_entered.connect(transition_entering_door)

	strive.text = str(strive_remaining)
	strive.modulate = Color.TRANSPARENT
	remaining.modulate = Color.TRANSPARENT
	
	door_number.modulate = Color.TRANSPARENT
	door_name.modulate = Color.TRANSPARENT

	failed.modulate = Color.TRANSPARENT
	sent.modulate = Color.TRANSPARENT
	limbo.modulate = Color.TRANSPARENT

	retry.disabled = true
	retry.modulate = Color.TRANSPARENT

	transition_entering_door()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func transition_to_ui():
	strive_remaining -= 1
	if tween: tween.kill()

	tween = create_tween()

	strive.text = str(strive_remaining)
	tween.tween_property(color_rect, "modulate", Color.WHITE, 0.5)
	tween.tween_property(color_rect, "modulate", Color.WHITE, 0.25)
	tween.chain().tween_property(strive, "modulate", Color.WHITE, 1)
	tween.chain().tween_property(remaining, "modulate", Color.WHITE, 1)
	tween.finished.connect(func():
		if strive_remaining > 0:
			transition_to_shop()
		else:
			transition_to_game_over()
	)

func transition_to_shop():
	state = STATES.IN_SHOP

func transition_entering_door():
	if tween: tween.kill()

	tween = create_tween()

	current_level += 1

	door_number.text = "GATE " + str(current_level)
	door_name.text = DOORS[current_level - 1]

	tween.tween_property(color_rect, "modulate", Color.WHITE, 0.5)
	tween.chain().tween_callback(EventBus.close_door.emit)
	tween.chain().tween_property(door_number, "modulate", Color.WHITE, 1)
	tween.chain().tween_property(door_number, "modulate", Color.WHITE, 1)
	tween.chain().tween_property(door_name, "modulate", Color.WHITE, 1)
	tween.chain().tween_property(door_name, "modulate", Color.WHITE, 1)

	tween.chain().tween_property(door_number, "modulate", Color.TRANSPARENT, 1)
	tween.parallel().tween_property(door_name, "modulate", Color.TRANSPARENT, 1)
	tween.chain().tween_property(color_rect, "modulate", Color.TRANSPARENT, 1)

	tween.finished.connect(func(): EventBus.new_level.emit(current_level))

func transition_to_game_over():
	state = STATES.IN_GAME_OVER
	retry.disabled = false

	if tween: tween.kill()
	tween = create_tween()
	
	tween.parallel().tween_property(strive, "modulate", Color.TRANSPARENT, 1)
	tween.parallel().tween_property(remaining, "modulate", Color.TRANSPARENT, 1)
	tween.parallel().tween_property(remaining, "modulate", Color.TRANSPARENT, 1)
	tween.chain().tween_property(failed, "modulate", Color.WHITE, 0.5)
	tween.chain().tween_property(failed, "modulate", Color.WHITE, 1)
	tween.chain().tween_property(sent, "modulate", Color.WHITE, 0.25)
	tween.chain().tween_property(sent, "modulate", Color.WHITE, 1)
	tween.chain().tween_property(limbo, "modulate", Color.hex(0xC43737ff), 0.75)
	tween.chain().tween_property(limbo, "modulate", Color.hex(0xC43737ff), 1)
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
