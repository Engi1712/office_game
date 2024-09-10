extends Control

@onready var cursor = $Cursor
@onready var ui = $".."

func _input(event):
	if event is InputEventMouseButton:	
		if ui.submenu_active and event.pressed:
			if event.button_index == 1:
				ui.cur_menu.left_click(cursor.position)
			elif event.button_index == 2:
				ui.cur_menu.right_click(cursor.position)
