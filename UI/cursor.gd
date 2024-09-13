extends Control

@onready var ui = $"../.."

func _ready():
	show()

func _physics_process(_delta):
	if position != get_viewport().get_mouse_position():
		position = get_viewport().get_mouse_position()
		if ui.submenu_active:
			ui.cur_menu.hover(position)
