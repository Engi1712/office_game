extends Panel

@onready var available_sprite = $Available
@onready var locked_sprite = $Locked
@onready var item_display = $Item

func _ready():
	set_locked()

func set_available():
	available_sprite.visible = true
	locked_sprite.visible = false

func set_locked():
	available_sprite.visible = false
	locked_sprite.visible = true

func set_item(item: InvItem):
	if !item:
		item_display.visible = false
	else:
		item_display.visible = true
		item_display.texture = item.texture
