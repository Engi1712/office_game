class_name InteractionArea extends Area2D

@export var interact_type = ""

@onready var object = get_parent()

func activate():
	object.touch(interact_type)

func deactivate():
	object.release(interact_type)

func enter():
	object.approach(interact_type)

func exit():
	object.leave(interact_type)
