extends Node2D
class_name PerkManager

@export var PERKS: Array[Perk]

func get_random_perk() -> Perk:
	if PERKS.size() > 0:
		return PERKS.pop_at(randi_range(0, PERKS.size() - 1))
	else:
		return null