class_name InteractionArea extends Area2D

@export var interact_label : String
@export var interact_type : String

@onready var object = get_parent()

func activate():
	object.touch()

func deactivate():
	object.release()

func enter():
	object.approach()

func exit():
	object.leave()
