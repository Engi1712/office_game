extends Control

@onready var inv_list: InvList = preload("res://GameData/Inventories/player_inv.tres")
@onready var slots: Array = $NinePatchRect/Grid.get_children()

var crafts = { 
	"plastic_cup_water": {
		"teabag": "plastic_cup_tea"
	}
}

var slot_selected: int = -1
var inv_size: int = 54
var transferring: bool
var remote_inv: Control
var cur_hover: int = -1

func _ready():
	hide()
	update_slots()

func update_slots():
	for i in range(slots.size()):
		slots[i].set_slot(inv_list.slots[i], "right", 2)
		if i < inv_size:
			slots[i].set_available()
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
	if cur_hover != -1:
		slots[cur_hover].hover_hide()
		cur_hover = -1
	hide()
	#get_tree().paused = false

func place_item(to: InvSlot, from: InvSlot):
	if (from.item and to.item and from.item.id == to.item.id):
		to.amount += from.amount
		from.item = null
		from.amount = 0
	else:
		var tmp = from.duplicate()
		from.set_values(to)
		to.set_values(tmp)

func merge_item(to: InvSlot, from: InvSlot):
	if crafts.has(to.item.id):
		if crafts[to.item.id].has(from.item.id):
			to.item = load("res://UI/Items/" + crafts[to.item.id][from.item.id] + ".tres")
			from.item = null
			from.amount = 0
			from.param1 = 0
			from.param2 = 0
			return true
	if crafts.has(from.item.id):
		if crafts[from.item.id].has(to.item.id):
			to.item = load("res://UI/Items/" + crafts[from.item.id][to.item.id] + ".tres")
			to.amount = from.amount
			to.param1 = from.param1
			to.param2 = from.param2
			from.item = null
			from.amount = 0
			from.param1 = 0
			from.param2 = 0
			return true
	return false

func left_click(point: Vector2):
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
	for i in range(inv_size):
		if slots[i].get_global_rect().has_point(point):
			if slot_selected != -1 and inv_list.slots[i].item:
				if merge_item(inv_list.slots[i], inv_list.slots[slot_selected]):
					slot_selected = -1
					update_slots()
			elif transferring and remote_inv.slot_selected != -1 and inv_list.slots[i].item:
				if merge_item(inv_list.slots[i], remote_inv.inv_list.slots[remote_inv.slot_selected]):
					remote_inv.slot_selected = -1
					update_slots()
					remote_inv.update_slots()
			break

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
	if !found_slot and cur_hover != -1:
		slots[cur_hover].hover_hide()
		cur_hover = -1
