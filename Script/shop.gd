class_name Shop
extends Resource

signal item_changed(indexes, is_player_items)

var items: Array[Perk] = [
	null, null, null, null, null, null
]

var player_items = [
	null, null, null
]

func set_item(index, item, is_player_item):
	var previous_item = null
	
	if is_player_item:
		previous_item = player_items[index]
		player_items[index] = item
	else:
		previous_item = items[index]
		items[index] = item
		
	item_changed.emit([index], [is_player_item])
	return previous_item

func swap_items(item_a_index, is_player_item_a, item_b_index, is_player_item_b):
	var item_a = items[item_a_index] if not is_player_item_a else player_items[item_a_index]
	var item_b = items[item_b_index] if not is_player_item_b else player_items[item_b_index]
	
	if is_player_item_a:
		player_items[item_a_index] = item_b
	else:
		items[item_a_index] = item_b

	if is_player_item_b:
		player_items[item_b_index] = item_a
	else:
		items[item_b_index] = item_a
		
	item_changed.emit([item_a_index, item_b_index], [is_player_item_a, is_player_item_b])

func remove_item(index, is_player_item):
	var item = null
	
	if is_player_item:
		item = player_items[index]
		player_items[index] = null
	else:
		item = items[index]
		items[index] = null
	
	item_changed.emit([index], [is_player_item])
	return item

func get_player_item(index):
	return player_items[index]

func get_shop_item(index):
	return items[index]
