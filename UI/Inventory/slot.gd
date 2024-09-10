extends Panel

@onready var available_sprite = $Available
@onready var locked_sprite = $Locked
@onready var selected_sprite = $Selected
@onready var content = $Content
@onready var item_display = $Content/Item
@onready var number10 = $Content/Number10
@onready var number1 = $Content/Number1

var cur_state: String
var mutex: Mutex
var free: bool

func _ready():
	mutex = Mutex.new()
	set_locked()
	content.visible = false
	free = true

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
	if !slot.item:
		content.visible = false
		free = true
	else:
		content.visible = true
		item_display.texture = slot.item.texture
		match slot.item.name:
			"plastic_cup":
				item_display.hframes = 11
				item_display.frame = slot.param / 20
			"plastic_cup_tea":
				item_display.hframes = 11
				item_display.frame = slot.param / 20
			_:
				item_display.hframes = 1
				item_display.frame = 0
		set_amount(slot.amount)
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
