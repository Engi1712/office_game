extends Control

@onready var ui = $"../.."
@onready var inventory = $"../Inventory"
@onready var slots: Array = $NinePatchRect/Grid.get_children()

var slot_selected: int
var inv_size: int
var inv_list: InvList

func _ready():
	hide()

func update_slots():
	inv_size = min(inv_list.items.size(), slots.size())
	for i in range(slots.size()):
		if i < inv_size:
			slots[i].set_available()
			slots[i].set_item(inv_list.items[i])
		else:
			slots[i].set_locked()
			slots[i].visible = false

func activate(inv_res: InvList):
	ui.submenu_active = true
	ui.cur_menu = self
	inv_list = inv_res
	update_slots()
	slot_selected = -1
	inventory.activate(self)
	show()

func deactivate():
	if slot_selected != -1:
		slots[slot_selected].set_available()
		slot_selected = -1
	hide()
	inventory.deactivate()
	ui.submenu_active = false

func click(point: Vector2):
	var found_slot = false
	for i in range(inv_size):
		if slots[i].get_global_rect().has_point(point):
			if slot_selected != -1:
				var tmp = inv_list.items[slot_selected]
				inv_list.items[slot_selected] = inv_list.items[i]
				inv_list.items[i] = tmp
				slot_selected = -1
				update_slots()
			elif inventory.slot_selected != -1:
				var tmp = inventory.inv_list.items[inventory.slot_selected]
				inventory.inv_list.items[inventory.slot_selected] = inv_list.items[i]
				inv_list.items[i] = tmp
				inventory.slot_selected = -1
				update_slots()
				inventory.update_slots()
			else:
				if !slots[i].free:
					slots[i].set_selected()
					slot_selected = i
			break
	if !found_slot:
		inventory.click(point)
