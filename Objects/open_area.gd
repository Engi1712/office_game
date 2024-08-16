extends Area2D

@export var zone_label = ""
@export var zone_type = "open"
@export var zone_value = ""

@onready var elevator = get_parent()

func open():
	elevator.open_entered()

func close():
	elevator.close_entered()
