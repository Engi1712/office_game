extends Control

@onready var main_panel = $Main
@onready var options_panel = $Options

signal closed

func _ready():
	hide()
	main_panel.visible = true
	options_panel.visible = false

func _input(event: InputEvent):
	if event.is_action_pressed("menu"):
		deactivate()

func activate():
	get_tree().paused = true
	show()

func deactivate():
	hide()
	get_tree().paused = false
	closed.emit()

func _on_resume_button_pressed():
	deactivate()

func _on_exit_desk_button_pressed():
	get_tree().quit()

func _on_options_button_pressed():
	main_panel.visible = false
	self.set_process_input(false)
	options_panel.activate()

func _on_options_closed():
	self.set_process_input(true)
	main_panel.visible = true
