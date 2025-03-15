extends Control

@onready var ui = $"../.."
@onready var inventory = $"../Inventory"
@onready var slots: Array = $NinePatchRect/Grid.get_children()

var select_slot = null
var hover_slot = null
var inv_list: InvList

func _ready():
	hide()

func update_slots():
	for i in range(slots.size()):
		if i < inv_list.slots.size():
			slots[i].set_slot(inv_list.slots[i])
			slots[i].visible = true
		else:
			slots[i].set_slot(null)
			slots[i].visible = false

func activate(inv_res: InvList):
	ui.cur_menu = self
	inv_list = inv_res
	update_slots()
	inventory.activate(self)
	show()

func deactivate():
	if select_slot:
		select_slot.deselect()
		select_slot = null
	if hover_slot:
		hover_slot.hover_hide()
		hover_slot = null
	hide()
	inventory.deactivate()
	ui.cur_menu = null

func get_slot(point: Vector2):
	for i in range(inv_list.slots.size()):
		if slots[i].get_global_rect().has_point(point):
			return slots[i]

func left_click(point: Vector2):
	var slot = get_slot(point)
	if !slot:
		inventory.left_click(point)
	elif select_slot:
		if slot != select_slot:
			if inventory.place_item(slot.cur_slot, select_slot.cur_slot) == 0:
				return
		select_slot.deselect()
		select_slot = null
		update_slots()
		hover_slot = slot
		hover_slot.hover_show()
	elif inventory.select_slot:
		if inventory.place_item(slot.cur_slot, inventory.select_slot.cur_slot) == 0:
			return
		inventory.select_slot.deselect()
		inventory.select_slot = null
		update_slots()
		inventory.update_slots()
		hover_slot = slot
		hover_slot.hover_show()
	else:
		if slot.cur_slot.item:
			select_slot = slot
			select_slot.select()

func right_click(point: Vector2):
	var slot = get_slot(point)
	if !slot:
		inventory.right_click(point);
	elif select_slot:
		if slot != select_slot:
			if inventory.merge_item(slot.cur_slot, select_slot.cur_slot):
				select_slot.deselect()
				select_slot = null
				update_slots()
				hover_slot = slot
				hover_slot.hover_show()
	elif inventory.select_slot:
		if inventory.merge_item(slot.cur_slot, inventory.select_slot.cur_slot):
			inventory.select_slot.deselect()
			inventory.select_slot = null
			update_slots()
			inventory.update_slots()
			hover_slot = slot
			hover_slot.hover_show()

func hover(point: Vector2):
	var slot = get_slot(point)
	if !slot:
		if hover_slot:
			hover_slot.hover_hide()
			hover_slot = null
		inventory.hover(point)
	else:
		if hover_slot:
			if slot != hover_slot:
				hover_slot.hover_hide()
				hover_slot = null
			else:
				return
		elif inventory.hover_slot:
			inventory.hover_slot.hover_hide()
			inventory.hover_slot = null
		hover_slot = slot
		hover_slot.hover_show()
