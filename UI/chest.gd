extends Control

@onready var ui = $"../.."
@onready var inventory = $"../Inventory"
@onready var slots: Array = $NinePatchRect/Grid.get_children()

var slot_selected: int
var inv_size: int
var inv_list: InvList
var cur_hover: int

func _ready():
	hide()

func update_slots():
	inv_size = inv_list.slots.size()
	for i in range(slots.size()):
		if i < inv_size:
			slots[i].set_available()
			slots[i].set_slot(inv_list.slots[i])
		else:
			slots[i].set_locked()
			slots[i].visible = false

func activate(inv_res: InvList):
	ui.submenu_active = true
	ui.cur_menu = self
	inv_list = inv_res
	update_slots()
	slot_selected = -1
	cur_hover = -1
	inventory.activate(self)
	show()

func deactivate():
	if slot_selected != -1:
		slots[slot_selected].set_available()
		slot_selected = -1
	hide()
	inventory.deactivate()
	ui.submenu_active = false

func left_click(point: Vector2):
	var found_slot = false
	for i in range(inv_size):
		if slots[i].get_global_rect().has_point(point):
			if slot_selected != -1:
				if i != slot_selected:
					inventory.place_item(inv_list.slots[i], inv_list.slots[slot_selected])
				slot_selected = -1
				update_slots()
			elif inventory.slot_selected != -1:
				if i != slot_selected:
					inventory.place_item(inv_list.slots[i], inventory.inv_list.slots[inventory.slot_selected])
				inventory.slot_selected = -1
				update_slots()
				inventory.update_slots()
			else:
				if !slots[i].free:
					slots[i].set_selected()
					slot_selected = i
			found_slot = true
			break
	if !found_slot:
		inventory.left_click(point)

func right_click(point: Vector2):
	var found_slot = false
	for i in range(inv_size):
		if slots[i].get_global_rect().has_point(point):
			if slot_selected != -1:
				if inventory.merge_item(inv_list.slots[i], inv_list.slots[slot_selected]):
					slot_selected = -1
					update_slots()
			elif inventory.slot_selected != -1:
				if inventory.merge_item(inv_list.slots[i], inventory.inv_list.slots[inventory.slot_selected]):
					inventory.slot_selected = -1
					update_slots()
					inventory.update_slots()
			found_slot = true
			break
	if !found_slot:
		inventory.right_click(point)

func hover(point: Vector2):
	var found_slot = false
	for i in range(inv_size):
		if slots[i].get_global_rect().has_point(point):
			if cur_hover != i:
				if cur_hover != -1:
					slots[cur_hover].hover_hide()
				slots[i].hover_show()
				cur_hover = i
			found_slot = true
			break
	if !found_slot:
		if cur_hover != -1:
			slots[cur_hover].hover_hide()
			cur_hover = -1
		inventory.hover(point)
