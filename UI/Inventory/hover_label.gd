extends Control

@onready var whole_panel = $Panel
@onready var hover_name = $Panel/Margins/HoverText/ItemName
@onready var hover_amount = $Panel/Margins/HoverText/ItemAmount
@onready var hover_size = $Panel/Margins/HoverText/ItemSize
@onready var hover_param1 = $Panel/Margins/HoverText/ItemParam1
@onready var hover_param2 = $Panel/Margins/HoverText/ItemParam2

var temp_gradient = ["52a3cc", "73bfe6", "99ddff", "cceeff", "ffffff", "ffcccc", "ff9999", "e67373", "cc5252"]
var grey = "999999"

func get_temp_color(degree: int):
	if degree < 21:
		return temp_gradient[(degree - 1) / 5]
	elif degree == 21:
		return temp_gradient[4]
	elif degree < 98:
		return temp_gradient[((degree - 21) / 19) + 5]
	else:
		return temp_gradient[8]

func fill_content(slot: InvSlot):
	if !slot:
		return
	hover_name.bbcode_text = slot.item.name
	hover_amount.bbcode_text = (str(slot.amount)
			+ "[color=" + grey + "]/"
			+ str(slot.item.stack_size)
			+ "[/color]")
	match slot.item.size:
		1:
			hover_size.bbcode_text = "SMALL"
		2:
			hover_size.bbcode_text = "MEDIUM"
		3:
			hover_size.bbcode_text = "LARGE"
		_:
			hover_size.bbcode_text = "?"
	match slot.item.id:
		"plastic_cup", "cup":
			hover_param1.bbcode_text = ("[color=" + grey + "]"
					+ str(slot.item.param)
					+ " "
					+ tr("SUFFIX_ML")
					+ "[/color]")
			hover_param1.visible = true
			hover_param2.text = ""
			hover_param2.visible = false
		"plastic_cup_water", "plastic_cup_tea", "plastic_cup_milk", "plastic_cup_coffee", "plastic_cup_apple_juice":
			hover_param1.bbcode_text = (str(slot.param1)
					+ "[color=" + grey + "]/"
					+ str(slot.item.param)
					+ "[/color] "
					+ tr("SUFFIX_ML"))
			hover_param1.visible = true
			hover_param2.text = ("[color="
					+ get_temp_color(slot.param2) + "]"
					+ str(slot.param2)
					+ "[/color]°C")
			hover_param2.visible = true
		_:
			hover_param1.text = ""
			hover_param1.visible = false
			hover_param2.text = ""
			hover_param2.visible = false

func get_height():
	return whole_panel.size.y
