extends CenterContainer

var shop: Shop = preload("res://Resource/shop.tres")
@onready var item_texture: TextureRect = $ItemTextureRect

func display_item(item):
	if item is Perk:
		item_texture.texture = item.icon
	else:
		item_texture.texture = load("res://Asset/no_perk.png")


func _get_drag_data(_at_position):
	var index = get_index()
	var item = shop.remove_item(index)
	if item is Perk:
		var data = {}
		data.item = item
		data.index = index
		var drag_preview = TextureRect.new()
		drag_preview.texture = item.icon
		set_drag_preview(drag_preview)
		return data

	return null

func _can_drop_data(_at_position, data):
	return data is Dictionary and data.has("item")

func _drop_data(_at_position, data):
	var my_index = get_index()
	shop.swap_items(my_index, data.index)
	shop.set_item(my_index, data.item)
