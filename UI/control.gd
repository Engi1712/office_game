extends Control

@onready var ui = $".."
@onready var toolbar = $Toolbar

func _input(event):
	if event is InputEventMouseButton:	
		if ui.cur_menu and event.pressed:
			if event.button_index == 1:
				ui.cur_menu.left_click(event.position)
			elif event.button_index == 2:
				ui.cur_menu.right_click(event.position)
	elif event is InputEventMouseMotion:
		if ui.cur_menu:
			ui.cur_menu.hover(event.position)
		else:
			toolbar.hover(event.position)
