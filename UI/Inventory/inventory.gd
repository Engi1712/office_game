extends Control

@onready var player_inv: InvChar = preload("res://GameData/Inventories/player_inv.tres")
@onready var jacket_slot = $NinePatchRect/JacketSlot
@onready var shirt_slot = $NinePatchRect/ShirtSlot
@onready var trousers_slot = $NinePatchRect/TrousersSlot
@onready var shoes_slot = $NinePatchRect/ShoesSlot
@onready var bag_slot = $NinePatchRect/BagSlot
@onready var hand_slot = $NinePatchRect/HandSlot
@onready var jacket_inv: Array = $NinePatchRect/JacketGrid.get_children()
@onready var trousers_inv: Array = $NinePatchRect/TrousersGrid.get_children()
@onready var bag_inv: Array = $NinePatchRect/BagGrid.get_children()
@onready var toolbar = $"../Toolbar"

var crafts = { 
	"plastic_cup_water": {
		"teabag": "plastic_cup_tea"
	}
}

var select_slot = null
var hover_slot = null
var remote_inv: Control = null

func _ready():
	hide()
	update_slots()

func _input(event: InputEvent):
	if Input.is_action_just_pressed("1"):
		toolbar_bind(1)
	elif Input.is_action_just_pressed("2"):
		toolbar_bind(2)
	elif Input.is_action_just_pressed("3"):
		toolbar_bind(3)
	elif Input.is_action_just_pressed("4"):
		toolbar_bind(4)
	elif Input.is_action_just_pressed("5"):
		toolbar_bind(5)

func update_slots():
	jacket_slot.set_slot(player_inv.jacket_slot)
	if player_inv.jacket_slot.inv:
		for i in range(jacket_inv.size()):
			jacket_inv[i].set_slot(player_inv.jacket_slot.inv.slots[i])
	else:
		for i in range(jacket_inv.size()):
			jacket_inv[i].set_slot(null)
	shirt_slot.set_slot(player_inv.shirt_slot)
	trousers_slot.set_slot(player_inv.trousers_slot)
	if player_inv.trousers_slot.inv:
		for i in range(trousers_inv.size()):
			trousers_inv[i].set_slot(player_inv.trousers_slot.inv.slots[i])
	else:
		for i in range(trousers_inv.size()):
			trousers_inv[i].set_slot(null)
	shoes_slot.set_slot(player_inv.shoes_slot)
	bag_slot.set_slot(player_inv.bag_slot)
	if player_inv.bag_slot.inv:
		for i in range(bag_inv.size()):
			if i < player_inv.bag_slot.inv.slots.size():
				bag_inv[i].set_slot(player_inv.bag_slot.inv.slots[i])
			else:
				bag_inv[i].set_slot(null)
	else:
		for i in range(bag_inv.size()):
			bag_inv[i].set_slot(null)
	hand_slot.set_slot(player_inv.hand_slot)

func activate(remote: Control):
	if remote:
		remote_inv = remote
	else:
		remote_inv = null
	#get_tree().paused = true
	show()

func deactivate():
	if select_slot:
		select_slot.deselect()
		select_slot = null
	if hover_slot:
		hover_slot.hover_hide()
		hover_slot = null
	hide()
	#get_tree().paused = false

func place_item(to: InvSlot, from: InvSlot):
	if from.item and to.capacity < from.item.size:
		return 0
	if to.item and from.capacity < to.item.size:
		return 0
	if from.item and to.type != "" and from.item.type != to.type:
		return 0
	if to.item and from.type != "" and to.item.type != from.type:
		return 0
	if (from.item and to.item and from.item.id == to.item.id):
		to.amount += from.amount
		from.item = null
		from.amount = 0
	else:
		var tmp = from.duplicate()
		from.set_values(to)
		to.set_values(tmp)
	return 1

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
			to.toolbar = from.toolbar
			from.item = null
			from.amount = 0
			from.param1 = 0
			from.param2 = 0
			from.toolbar = 0
			return true
	return false

func get_slot(point: Vector2):
	if jacket_slot.get_global_rect().has_point(point):
		return jacket_slot
	if shirt_slot.get_global_rect().has_point(point):
		return shirt_slot
	if trousers_slot.get_global_rect().has_point(point):
		return trousers_slot
	if shoes_slot.get_global_rect().has_point(point):
		return shoes_slot
	if bag_slot.get_global_rect().has_point(point):
		return bag_slot
	if player_inv.jacket_slot.inv:
		for i in range(player_inv.jacket_slot.inv.slots.size()):
			if jacket_inv[i].get_global_rect().has_point(point):
				return jacket_inv[i]
	if player_inv.trousers_slot.inv:
		for i in range(player_inv.trousers_slot.inv.slots.size()):
			if trousers_inv[i].get_global_rect().has_point(point):
				return trousers_inv[i]
	if player_inv.bag_slot.inv:
		for i in range(player_inv.bag_slot.inv.slots.size()):
			if bag_inv[i].get_global_rect().has_point(point):
				return bag_inv[i]
	if hand_slot.get_global_rect().has_point(point):
		return hand_slot
	return null

func left_click(point: Vector2):
	var slot = get_slot(point)
	if !slot:
		return
	elif select_slot:
		if slot != select_slot:
			if place_item(slot.cur_slot, select_slot.cur_slot) == 0:
				return
		select_slot.deselect()
		select_slot = null
		update_slots()
		hover_slot = slot
		hover_slot.hover_show()
	elif remote_inv and remote_inv.select_slot:
		if place_item(slot.cur_slot, remote_inv.select_slot.cur_slot) == 0:
			return
		remote_inv.select_slot.deselect()
		remote_inv.select_slot = null
		update_slots()
		remote_inv.update_slots()
		hover_slot = slot
		hover_slot.hover_show()
	else:
		if slot.cur_slot.item:
			select_slot = slot
			select_slot.select()

func right_click(point: Vector2):
	var slot = get_slot(point)
	if !slot:
		return
	elif select_slot:
		if slot != select_slot:
			if merge_item(slot.cur_slot, select_slot.cur_slot):
				select_slot.deselect()
				select_slot = null
				update_slots()
				hover_slot = slot
				hover_slot.hover_show()
	elif remote_inv and remote_inv.select_slot:
		if merge_item(slot.cur_slot, remote_inv.select_slot.cur_slot):
			remote_inv.select_slot.deselect()
			remote_inv.select_slot = null
			update_slots()
			remote_inv.update_slots()
			hover_slot = slot
			hover_slot.hover_show()

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
		elif remote_inv and remote_inv.hover_slot:
			remote_inv.hover_slot.hover_hide()
			remote_inv.hover_slot = null
		hover_slot = slot
		hover_slot.hover_show()

func toolbar_bind(num: int):
	if select_slot:
		if select_slot.cur_slot.toolbar != 0:
			toolbar.unbind(select_slot.cur_slot.toolbar)
			select_slot.cur_slot.toolbar = 0
		var slot = toolbar.get_bind(num)
		if slot:
			toolbar.unbind(num)
			slot.cur_slot.toolbar = 0
			slot.update_toolbar()
		toolbar.bind(select_slot, num)
		select_slot.cur_slot.toolbar = num
		select_slot.update_toolbar()
