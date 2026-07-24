extends Control

var shop: Shop = preload("res://Resource/shop.tres")


func _can_drop_data(_at_position, data):
	return data is Dictionary and data.has("item")

func _drop_data(_at_position, data):
	shop.set_item(data.index, data.item)
