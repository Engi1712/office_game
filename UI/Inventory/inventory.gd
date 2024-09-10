extends Control

@onready var inv_list: InvList = preload("res://GameData/Inventories/player_inv.tres")
@onready var slots: Array = $NinePatchRect/Grid.get_children()

var crafts = { 
	"plastic_cup": {
		"teabag": "plastic_cup_tea"
	}
}

var slot_selected: int
var inv_size: int = 12
var transferring: bool
var remote_inv: Control

func _ready():
	hide()
	update_slots()
	slot_selected = -1

func update_slots():
	for i in range(slots.size()):
		if i < inv_size:
			slots[i].set_available()
			slots[i].set_slot(inv_list.slots[i])
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

func place_item(to: InvSlot, from: InvSlot):
	if (from.item and to.item and from.item.name == to.item.name and from.param == 0 and to.param == 0):
		to.amount += from.amount
		from.item = null
		from.amount = 0
	else:
		var tmp = from.duplicate()
		from.set_values(to)
		to.set_values(tmp)

func merge_item(to: InvSlot, from: InvSlot):
	if crafts.has(to.item.name):
		if crafts[to.item.name].has(from.item.name):
			to.item = load("res://UI/Items/" + crafts[to.item.name][from.item.name] + ".tres")
			from.item = null
			from.amount = 0
			from.param = 0
			return true
	if crafts.has(from.item.name):
		if crafts[from.item.name].has(to.item.name):
			to.item = load("res://UI/Items/" + crafts[from.item.name][to.item.name] + ".tres")
			to.amount = from.amount
			to.param = from.param
			from.item = null
			from.amount = 0
			from.param = 0
			return true
	return false

func left_click(point: Vector2):
	print("Left")
	for i in range(inv_size):
		if slots[i].get_global_rect().has_point(point):
			if slot_selected != -1:
				if i != slot_selected:
					place_item(inv_list.slots[i], inv_list.slots[slot_selected])
				slot_selected = -1
				update_slots()
			elif transferring and remote_inv.slot_selected != -1:
				if i != slot_selected:
					place_item(inv_list.slots[i], remote_inv.inv_list.slots[remote_inv.slot_selected])
				remote_inv.slot_selected = -1
				update_slots()
				remote_inv.update_slots()
			else:
				if !slots[i].free:
					slots[i].set_selected()
					slot_selected = i
			break

func right_click(point: Vector2):
	print("Right")
	for i in range(inv_size):
		if slots[i].get_global_rect().has_point(point):
			if slot_selected != -1:
				if merge_item(inv_list.slots[i], inv_list.slots[slot_selected]):
					slot_selected = -1
					update_slots()
			elif transferring and remote_inv.slot_selected != -1:
				if merge_item(inv_list.slots[i], remote_inv.inv_list.slots[remote_inv.slot_selected]):
					remote_inv.slot_selected = -1
					update_slots()
					remote_inv.update_slots()
			break
