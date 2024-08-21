extends Control

@onready var inventory = get_node("../Inventory")

func _ready():
	hide()

func activate():
	inventory.activate()
	show()

func deactivate():
	hide()
	inventory.deactivate()
