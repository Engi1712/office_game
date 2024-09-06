extends Control

@onready var inv_list: InvList = preload("res://GameData/Inventories/player_inv.tres")
@onready var slots: Array = $NinePatchRect/Grid.get_children()

var slot_selected: int
var inv_size: int
var transferring: bool
var remote_inv: Control

func _ready():
	hide()
	update_slots()
	slot_selected = -1

func update_slots():
	inv_size = min(inv_list.items.size(), slots.size())
	for i in range(slots.size()):
		if i < inv_size:
			slots[i].set_available()
			slots[i].set_item(inv_list.items[i])
		else:
			slots[i].set_locked()

func activate(remote: Control):
	if remote:
		remote_inv = remote
		transferring = true
	else:
		transferring = false
	#get_tree().paused = true
	show()

func deactivate():
	if slot_selected != -1:
		slots[slot_selected].set_available()
		slot_selected = -1
	hide()
	#get_tree().paused = false

func click(point: Vector2):
	for i in range(inv_size):
		if slots[i].get_global_rect().has_point(point):
			if slot_selected != -1:
				var tmp = inv_list.items[slot_selected]
				inv_list.items[slot_selected] = inv_list.items[i]
				inv_list.items[i] = tmp
				slot_selected = -1
				update_slots()
			elif transferring and remote_inv.slot_selected != -1:
				var tmp = remote_inv.inv_list.items[remote_inv.slot_selected]
				remote_inv.inv_list.items[remote_inv.slot_selected] = inv_list.items[i]
				inv_list.items[i] = tmp
				remote_inv.slot_selected = -1
				update_slots()
				remote_inv.update_slots()
			else:
				if !slots[i].free:
					slots[i].set_selected()
					slot_selected = i
			break
