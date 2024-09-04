extends Control

@onready var ui = $"../.."
@onready var inventory = $"../Inventory"
@onready var slots: Array = $NinePatchRect/Grid.get_children()

func _ready():
	hide()

func update_slots(inv_list: InvList):
	var cur_inv_size = min(inv_list.items.size(), slots.size())
	for i in range(slots.size()):
		if i < cur_inv_size:
			slots[i].set_available()
			slots[i].set_item(inv_list.items[i])
		else:
			slots[i].set_locked()
			slots[i].visible = false

func activate(inv_list: InvList):
	ui.submenu_active = true
	ui.cur_menu = self
	update_slots(inv_list)
	inventory.activate()
	show()

func deactivate():
	hide()
	inventory.deactivate()
	ui.submenu_active = false
