extends Resource

class_name InvSlot

@export var item: InvItem
@export var amount: int = 0
@export var param1: int = 0
@export var param2: int = 0

func set_values(slot: InvSlot):
	item = slot.item
	amount = slot.amount
	param1 = slot.param1
	param2 = slot.param2
