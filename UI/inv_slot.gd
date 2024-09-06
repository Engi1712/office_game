extends Panel

@onready var available_sprite = $Available
@onready var locked_sprite = $Locked
@onready var selected_sprite = $Selected
@onready var item_display = $Item

var cur_state: String
var mutex: Mutex
var free: bool

func _ready():
	mutex = Mutex.new()
	set_locked()
	cur_state = "locked"
	free = true

func set_available():
	mutex.lock()
	available_sprite.visible = true
	locked_sprite.visible = false
	selected_sprite.visible = false
	cur_state = "available"
	mutex.unlock()

func set_locked():
	mutex.lock()
	available_sprite.visible = false
	locked_sprite.visible = true
	selected_sprite.visible = false
	cur_state = "locked"
	mutex.unlock()

func set_selected():
	mutex.lock()
	available_sprite.visible = false
	locked_sprite.visible = false
	selected_sprite.visible = true
	cur_state = "selected"
	mutex.unlock()

func set_item(item: InvItem):
	if !item:
		item_display.visible = false
		free = true
	else:
		item_display.visible = true
		item_display.texture = item.texture
		free = false
