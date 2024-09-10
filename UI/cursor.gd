extends Control

func _ready():
	show()

func _physics_process(_delta):
	position = get_viewport().get_mouse_position()
