extends Node2D
class_name PerkManager

var shop: Shop = preload("res://Resource/shop.tres")
@export var PERKS: Array[Perk]

func get_random_perk() -> Perk:
	if PERKS.size() > 0:
		return PERKS.pop_at(randi_range(0, PERKS.size() - 1))
	else:
		return null

func add_perk(perk: Perk):
	PERKS.append(perk)