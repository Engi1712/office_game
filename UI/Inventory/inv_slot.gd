extends Resource

class_name InvSlot

@export var item: InvItem
@export var amount: int = 0
@export var param: int = 0

func set_values(slot: InvSlot):
	item = slot.item
	amount = slot.amount
	param = slot.param
