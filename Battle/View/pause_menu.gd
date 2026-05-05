extends Control

signal resume_button_pressed
signal restart_button_pressed
signal exit_button_pressed

var opened: bool

func _ready():
	close()

func open():
	opened = true
	show()

func close():
	opened = false
	hide()

func is_opened():
	return opened

func _on_resume_pressed():
	resume_button_pressed.emit()

func _on_restart_pressed():
	restart_button_pressed.emit()

func _on_exit_pressed():
	exit_button_pressed.emit()
