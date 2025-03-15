extends Resource

class_name InvSlot

@export var item: InvItem
@export var amount: int = 0
@export var inv: InvList
@export var param1: int = 0
@export var param2: int = 0
@export var toolbar: int = 0
@export var capacity: int = 0
@export var type: String = ""
@export var hover_side: String = "r"

func set_values(slot: InvSlot):
	item = slot.item
	amount = slot.amount
	inv = slot.inv
	param1 = slot.param1
	param2 = slot.param2
	toolbar = slot.toolbar
