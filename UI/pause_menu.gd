extends Control

func _ready():
	hide()

func activate():
	get_tree().paused = true
	show()

func deactivate():
	hide()
	get_tree().paused = false
