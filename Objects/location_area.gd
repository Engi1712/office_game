class_name LocationArea extends Area2D

@export var location_type = ""

@onready var object = get_parent()

func enter():
	object.approach(location_type)

func exit():
	object.leave(location_type)
