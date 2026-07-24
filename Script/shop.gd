class_name Shop
extends Resource

signal item_changed(indexes)
signal player_item_changed(indexes)

var items: Array[Perk] = [
	null, null, null, null, null, null
]

var player_items = [
	null, null, null
]

func set_item(index, item):
	var previous_item = items[index]
	items[index] = item
	item_changed.emit([index])
	return previous_item

func swap_items(item_a_index, item_b_index):
	var item_a = items[item_a_index]
	var item_b = items[item_b_index]
	items[item_a_index] = item_b
	items[item_b_index] = item_a
	item_changed.emit([item_a_index, item_b_index])

func remove_item(index):
	var item = items[index]
	items[index] = null
	item_changed.emit([index])
	return item
