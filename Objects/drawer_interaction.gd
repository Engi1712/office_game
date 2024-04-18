class_name DrawerInteraction extends Area2D

@export var interact_label = "none"
@export var interact_type = "none"
@export var interact_value = "none"
@export var interact_active = false

@onready var drawer = get_parent()

func touch():
	if interact_active:
		drawer.is_open = false
		interact_active = false
	else:
		drawer.is_open = true
		interact_active = true
