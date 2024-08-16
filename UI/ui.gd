extends CanvasLayer

@export var submenu_active = false
@export var cur_menu : Control

@onready var pause_menu = $"Control/PauseMenu"
@onready var elevator_panel = $"Control/ElevatorPanel"
@onready var inventory = $"Control/Inventory"
@onready var toolbar = $"Control/Toolbar"

func _ready():
	toolbar.activate()

func _input(event : InputEvent):
	if event.is_action_pressed("menu"):
		if submenu_active:
			cur_menu.deactivate()
			submenu_active = false
		else:
			submenu_active = true
			cur_menu = pause_menu
			pause_menu.activate()
	elif event.is_action_pressed("inv"):
		if submenu_active:
			if cur_menu == inventory:
				inventory.deactivate()
				submenu_active = false
		else:
			submenu_active = true
			cur_menu = inventory
			inventory.activate()

func elevator_panel_toggle(elevator_id):
	submenu_active = true
	cur_menu = elevator_panel
	elevator_panel.activate(elevator_id)
