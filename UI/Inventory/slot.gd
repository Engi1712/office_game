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
@onready var hover_param = $HoverLabel/Margins/HoverText/ItemParam

var cur_state: String
var mutex: Mutex
var free: bool
var cur_slot: InvSlot

func _ready():
	mutex = Mutex.new()
	set_locked()
	content.visible = false
	free = true
	cur_slot = null
	Game.on_translation_updated.connect(update_text)
	hover_hide()

func update_text():
	set_slot(cur_slot)

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

func set_slot(slot: InvSlot):
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
			"plastic_cup_water":
				item_display.hframes = 10
				item_display.frame = (slot.param - 1) / 20
			"plastic_cup_tea":
				item_display.hframes = 10
				item_display.frame = (slot.param - 1) / 20
			_:
				item_display.hframes = 1
				item_display.frame = 0
		set_amount(slot.amount)
		hover_name.text = slot.item.name
		match slot.item.id:
			"plastic_cup_water":
				if slot.param != 0:
					hover_param.text = str(slot.param) + " " + tr("SUFFIX_ML")
			"plastic_cup_tea":
				if slot.param != 0:
					hover_param.text = str(slot.param) + " " + tr("SUFFIX_ML")
			_:
				hover_param.text = ""
		free = false

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
		print(position)
		print(hover_label.position)
		hover_label.show()

func hover_hide():
	hover_label.hide()
