class_name DoorSInteraction extends Area2D

@export var interact_label = ""
@export var interact_type = "door"
@export var interact_value = ""
@export var interact_active = false

@onready var door = get_parent()

func touch():
	if interact_active:
		door.is_open = false
		interact_active = false
	else:
		door.is_open = true
		interact_active = true
