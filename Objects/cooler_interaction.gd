class_name CoolerInteraction extends Area2D

@export var interact_label = "none"
@export var interact_type = "none"
@export var interact_value = "none"
@export var interact_active = false

@onready var cooler = get_parent()

func fill():
	cooler.is_filled = true
	interact_active = true

func stop():
	cooler.is_filled = false
	interact_active = false
