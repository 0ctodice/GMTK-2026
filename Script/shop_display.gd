extends GridContainer

var shop: Shop = preload("res://Resource/shop.tres")
var perk_manager: PerkManager

func _ready():
	perk_manager = get_tree().get_first_node_in_group("PerkManager")
	shop.item_changed.connect(on_items_changed)
	update_shop_display()

func update_shop_display():
	for index in shop.items.size():
		shop.items[index] = perk_manager.get_random_perk()
		update_shop_slot_display(index)

func update_shop_slot_display(index):
	var slot_display = get_child(index)
	var item = shop.items[index]
	slot_display.display_item(item)

func on_items_changed(indexes):
	for index in indexes:
		update_shop_slot_display(index)
