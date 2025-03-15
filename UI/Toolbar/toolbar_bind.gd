extends Control

@onready var bind_id = $Number
@onready var content = $Content
@onready var item_display = $Content/Item
@onready var number10 = $Content/Number10
@onready var number1 = $Content/Number1
@onready var hover_label = $HoverLabel

@export var cur_slot: InvSlot = null
@export var id: int = 0

func _ready():
	content.visible = false
	if id != 0:
		bind_id.frame = id 

func bind(slot: InvSlot):
	cur_slot = slot
	if !slot or !slot.item:
		content.visible = false
	else:
		item_display.texture = slot.item.texture
		match slot.item.id:
			"plastic_cup_water", "plastic_cup_tea", "plastic_cup_milk", "plastic_cup_coffee", "plastic_cup_apple_juice":
				item_display.hframes = 10
				item_display.frame = (slot.param1 - 1) / 20
			_:
				item_display.hframes = 1
				item_display.frame = 0
		set_amount(slot.amount)
		content.visible = true
		hover_label.fill_content(slot)
		hover_label.position.y = 0

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
	if cur_slot and cur_slot.item:
		hover_label.show()
		await get_tree().process_frame
		hover_label.hide()
		var pixels_down = Game.resolution.y - hover_label.global_position.y
		if pixels_down < hover_label.get_height():
			hover_label.position.y -= hover_label.get_height() - pixels_down
		hover_label.show()

func hover_hide():
	hover_label.hide()
