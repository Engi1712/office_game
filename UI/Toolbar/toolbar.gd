extends Control

@onready var toolbar_binds = $NinePatchRect/ToolbarGrid.get_children()

var binding_slots: Array
var hover_slot = null

func _ready():
	hide()
	for i in range(toolbar_binds.size()):
		binding_slots.append(null)

func activate():
	show()

func deactivate():
	hide()

func bind(slot: Control, num: int):
	if num > 0 and num <= toolbar_binds.size():
		binding_slots[num - 1] = slot
		toolbar_binds[num - 1].bind(slot.cur_slot)

func unbind(num: int):
	if num > 0 and num <= toolbar_binds.size():
		binding_slots[num - 1] = null
		toolbar_binds[num - 1].bind(null)

func get_bind(num: int):
	if num > 0 and num <= toolbar_binds.size():
		return binding_slots[num - 1]
	else:
		return null

func get_slot(point: Vector2):
	for i in range(toolbar_binds.size()):
		if toolbar_binds[i].get_global_rect().has_point(point):
			return toolbar_binds[i]

func hover(point: Vector2):
	var slot = get_slot(point)
	if !slot:
		if hover_slot:
			hover_slot.hover_hide()
			hover_slot = null
	else:
		if hover_slot:
			if slot != hover_slot:
				hover_slot.hover_hide()
				hover_slot = null
			else:
				return
		hover_slot = slot
		hover_slot.hover_show()
