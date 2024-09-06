extends Control

@onready var cursor = $Cursor
@onready var ui = $".."

func _input(event):
	if event is InputEventMouseButton:	
		if ui.submenu_active and event.pressed:
			ui.cur_menu.click(cursor.position)
