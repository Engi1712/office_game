extends Panel

@onready var available_sprite = $Available
@onready var locked_sprite = $Locked
@onready var selected_sprite = $Selected
@onready var capacity_sprite = $Capacity
@onready var placeholder_sprite = $Placeholder
@onready var content = $Content
@onready var item_display = $Content/Item
@onready var number10 = $Content/Number10
@onready var number1 = $Content/Number1
@onready var toolbar = $Content/Toolbar
@onready var hover_label = $HoverLabel

@export var cur_slot: InvSlot = null
@export var placeholder: Texture = null

func _ready():
	Game.on_translation_updated.connect(update_text)
	placeholder_sprite.texture = placeholder
	hover_label.hide()
	deselect()
	update()

func update_text():
	if cur_slot and cur_slot.item:
		hover_label.fill_content(cur_slot)

func set_slot(slot: InvSlot):
	cur_slot = slot
	update()

func update():
	if !cur_slot:
		locked_sprite.visible = true
	elif !cur_slot.item:
		locked_sprite.visible = false
		content.visible = false
		placeholder_sprite.visible = true
		update_capacity()
	else:
		update_item()
		update_amount()
		locked_sprite.visible = false
		content.visible = true
		placeholder_sprite.visible = false
		update_capacity()
		update_hover()
		update_toolbar()

func update_item():
	item_display.texture = cur_slot.item.texture
	match cur_slot.item.id:
		"plastic_cup_water", "plastic_cup_tea", "plastic_cup_milk", "plastic_cup_coffee", "plastic_cup_apple_juice":
			item_display.hframes = 10
			item_display.frame = (cur_slot.param1 - 1) / 20
		_:
			item_display.hframes = 1
			item_display.frame = 0

func update_amount():
	if cur_slot.amount == 1 or cur_slot.amount == 0:
		number10.visible = false
		number1.visible = false
	else:
		if cur_slot.amount / 10 == 0:
			number10.visible = false
		else:
			number10.frame = cur_slot.amount / 10
			number10.visible = true
		number1.frame = cur_slot.amount % 10
		number1.visible = true

func update_hover():
	hover_label.fill_content(cur_slot)
	hover_label.position.y = 0
	if cur_slot.hover_side == "l":
		hover_label.position.x = -153

func update_capacity():
	if cur_slot.capacity == 0:
		capacity_sprite = null
	else:
		capacity_sprite.texture = load("res://Art/Office Pack/HUD/capacity" + str(cur_slot.capacity) + ".png")
		capacity_sprite.hframes = cur_slot.capacity + 1
		if !cur_slot.item:
			capacity_sprite.frame = 0
		else:
			capacity_sprite.frame = cur_slot.item.size

func update_toolbar():
	if cur_slot.toolbar < 1 or cur_slot.toolbar > 5:
		toolbar.visible = false
	else:
		toolbar.frame = cur_slot.toolbar
		toolbar.visible = true

func select():
	selected_sprite.visible = true

func deselect():
	selected_sprite.visible = false

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
