class_name LockerInteraction extends Area2D

@export var interact_label = "none"
@export var interact_type = "none"
@export var interact_value = "none"
@export var interact_active = false

@onready var locker = get_parent()

func touch():
	if interact_active:
		locker.is_open = false
		interact_active = false
	else:
		locker.is_open = true
		interact_active = true
