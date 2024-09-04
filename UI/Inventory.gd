extends Control

@onready var inv_list: InvList = preload("res://GameData/Inventories/player_inv.tres")
@onready var slots: Array = $NinePatchRect/Grid.get_children()

func _ready():
	hide()
	update_slots()

func update_slots():
	var cur_inv_size = min(inv_list.items.size(), slots.size())
	for i in range(slots.size()):
		if i < cur_inv_size:
			slots[i].set_available()
			slots[i].set_item(inv_list.items[i])
		else:
			slots[i].set_locked()

func activate():
	#get_tree().paused = true
	show()

func deactivate():
	hide()
	#get_tree().paused = false
