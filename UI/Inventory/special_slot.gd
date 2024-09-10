extends Panel

@onready var available_sprite = $Available
@onready var locked_sprite = $Locked
@onready var selected_sprite = $Selected
@onready var placeholder_sprite = $Placeholder
@onready var content = $Content
@onready var item_display = $Content/Item

@export var placeholder_texture: Texture2D

var cur_state: String
var mutex: Mutex
var free: bool

func _ready():
	mutex = Mutex.new()
	set_available()
	content.visible = false
	free = true
	placeholder_sprite.texture = placeholder_texture
	placeholder_sprite.visible = true

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
		placeholder_sprite.visible = true
	else:
		content.visible = true
		item_display.texture = slot.item.texture
		item_display.hframes = 1
		item_display.frame = 0
		free = false
		placeholder_sprite.visible = true
