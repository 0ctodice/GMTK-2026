class_name Perk
extends Resource

@export var icon: Texture2D
@export var name: String
@export var description: String
@export_range(0, 100) var damage: int
@export_range(0, 100) var cooldown: float
@export_range(1, 3) var level: int
@export var scene: PackedScene

func _init(_icon = null, _name = "placeholder", _description = "NONE", _damage = 1, _cooldown = 0, _level = 1, _scene = null):
	name = _name
	icon = _icon
	damage = _damage
	description = _description
	cooldown = _cooldown
	level = _level
	scene = _scene