extends Panel

@onready var available_sprite = $Available
@onready var locked_sprite = $Locked
@onready var selected_sprite = $Selected
@onready var content = $Content
@onready var item_display = $Content/Item
@onready var number10 = $Content/Number10
@onready var number1 = $Content/Number1
@onready var hover_label = $HoverLabel
@onready var hover_name = $HoverLabel/Margins/HoverText/ItemName
@onready var hover_amount = $HoverLabel/Margins/HoverText/ItemAmount
@onready var hover_param1 = $HoverLabel/Margins/HoverText/ItemParam1
@onready var hover_param2 = $HoverLabel/Margins/HoverText/ItemParam2

var cur_state: String
var mutex: Mutex
var free: bool = true
var cur_slot: InvSlot = null
var cur_hover_side = "right"
var temp_gradient = ["52a3cc", "73bfe6", "99ddff", "cceeff", "ffffff", "ffcccc", "ff9999", "e67373", "cc5252"]
var grey = "999999"

func _ready():
	mutex = Mutex.new()
	set_locked()
	content.visible = false
	cur_slot = null
	Game.on_translation_updated.connect(update_text)
	hover_name.resized.connect(hover_resize)
	hover_hide()

func get_temp_color(degree: int):
	if degree < 21:
		return temp_gradient[(degree - 1) / 5]
	elif degree == 21:
		return temp_gradient[4]
	elif degree < 98:
		return temp_gradient[((degree - 21) / 19) + 5]
	else:
		return temp_gradient[8]

func update_text():
	set_slot(cur_slot, cur_hover_side)

func set_available():
	mutex.lock()
	locked_sprite.visible = false
	selected_sprite.visible = false
	cur_state = "available"
	mutex.unlock()

func set_locked():
	mutex.lock()
	locked_sprite.visible = true
	selected_sprite.visible = false
	cur_state = "locked"
	mutex.unlock()

func set_selected():
	mutex.lock()
	locked_sprite.visible = false
	selected_sprite.visible = true
	cur_state = "selected"
	mutex.unlock()

func set_slot(slot: InvSlot, hover_side: String):
	cur_slot = slot
	if !slot:
		return
	if !slot.item:
		content.visible = false
		free = true
	else:
		content.visible = true
		item_display.texture = slot.item.texture
		match slot.item.id:
			"plastic_cup_water", "plastic_cup_tea", "plastic_cup_milk", "plastic_cup_coffee":
				item_display.hframes = 10
				item_display.frame = (slot.param1 - 1) / 20
			_:
				item_display.hframes = 1
				item_display.frame = 0
		set_amount(slot.amount)
		hover_name.bbcode_text = slot.item.name
		hover_amount.bbcode_text = (str(slot.amount)
				+ "[color=" + grey + "]/"
				+ str(slot.item.stack_size)
				+ "[/color]")
		match slot.item.id:
			"plastic_cup":
				hover_param1.bbcode_text = ("[color=" + grey + "]"
						+ str(slot.item.param)
						+ " "
						+ tr("SUFFIX_ML")
						+ "[/color]")
			"plastic_cup_water", "plastic_cup_tea", "plastic_cup_milk", "plastic_cup_coffee":
				hover_param1.bbcode_text = (str(slot.param1)
						+ "[color=" + grey + "]/"
						+ str(slot.item.param)
						+ "[/color] "
						+ tr("SUFFIX_ML"))
				hover_param2.bbcode_text = ("[color="
						+ get_temp_color(slot.param2) + "]"
						+ str(slot.param2)
						+ "[/color]°C")
				print(slot.param2)
			_:
				hover_param1.text = ""
		free = false
		cur_hover_side = hover_side
		if hover_side == "left":
			hover_label.position.x = -153

func set_amount(amount: int):
	if amount == 1 or amount == 0:
		number10.visible = false
		number1.visible = false
	else:
		if amount / 10 == 0:
			number10.visible = false
		else:
			number10.frame = amount / 10
			number10.visible = true
		number1.frame = amount % 10
		number1.visible = true

func hover_show():
	if !free:
		#hover_label.position.x = position.x - hover_label.size.x - 3
		#hover_label.position.x = - hover_label.size.x - 3
		#await get_tree().process_frame
		print(position)
		print(hover_label.position)
		print(hover_name.size)
		print(hover_label.size)
		print("\n")
		hover_label.show()

func hover_resize():
	print("Resize ")
	print(hover_name.size)
	#hover_label.position.x = - hover_label.size.x - 3

func hover_hide():
	hover_label.hide()
