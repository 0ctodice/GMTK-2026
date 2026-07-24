extends GridContainer

var shop: Shop = preload("res://Resource/shop.tres")
var perk_manager: PerkManager

func _ready():
	perk_manager = get_tree().get_first_node_in_group("PerkManager")
	shop.item_changed.connect(on_items_changed)
	EventBus.update_shop.connect(update_shop_display)
	EventBus.clear_shop.connect(clear_shop_display)

func update_shop_display():
	for index in shop.items.size():
		shop.items[index] = perk_manager.get_random_perk()
		update_shop_slot_display(index)

func update_shop_slot_display(index):
	var slot_display = get_child(index)
	var item = shop.items[index]
	slot_display.display_item(item)

func on_items_changed(indexes, is_player_items):
	for i in range(indexes.size()):
		if not is_player_items[i]:
			update_shop_slot_display(indexes[i])


func clear_shop_display():
	for index in shop.items.size():
		var perk = shop.remove_item(index, false)
		if perk != null:
			perk_manager.add_perk(perk)
			update_shop_slot_display(index)
