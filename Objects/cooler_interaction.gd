class_name CoolerInteraction extends Area2D

@export var interact_label = "none"
@export var interact_type = "none"
@export var interact_value = "none"

@onready var cooler = get_parent()

func fill():
	cooler.is_filled = true
