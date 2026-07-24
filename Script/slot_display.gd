extends CenterContainer

@export var is_player_item: bool = false
var shop: Shop = preload("res://Resource/shop.tres")
@onready var item_texture: TextureRect = $ItemTextureRect
@onready var data_container: PanelContainer = $ItemTextureRect/PanelContainer
@onready var data_label_name: Label = $ItemTextureRect/PanelContainer/VBox/Name
@onready var data_label_dmg: Label = $ItemTextureRect/PanelContainer/VBox/Damage
@onready var data_label_desc: Label = $ItemTextureRect/PanelContainer/VBox/Description

func _ready():
	data_container.visible = false

func display_item(item):
	if item is Perk:
		item_texture.texture = item.icon
	else:
		item_texture.texture = load("res://Asset/no_perk.png")


func _get_drag_data(_at_position):
	var index = get_index()
	var item = shop.remove_item(index, is_player_item)
	if item is Perk:
		var data = {}
		data.item = item
		data.index = index
		data.is_player_item = is_player_item
		var drag_preview = TextureRect.new()
		drag_preview.texture = item.icon
		set_drag_preview(drag_preview)
		return data

	return null

func _can_drop_data(_at_position, data):
	return data is Dictionary and data.has("item")

func _drop_data(_at_position, data):
	var my_index = get_index()
	shop.swap_items(my_index, is_player_item, data.index, data.is_player_item)
	shop.set_item(my_index, data.item, is_player_item)

func _on_mouse_entered():
	var item: Perk = null
	if is_player_item:
		item = shop.get_player_item(get_index())
	else:
		item = shop.get_shop_item(get_index())

	if item != null:
		data_label_name.text = item.name + " - Lvl: " + str(item.level)
		data_label_dmg.text = "damage : " + str(item.damage)
		data_label_desc.text = item.description
		data_container.visible = true


func _on_mouse_exited():
	data_container.visible = false
