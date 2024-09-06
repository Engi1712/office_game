extends CanvasLayer

@export var submenu_active = false
@export var cur_menu : Control

@onready var pause_menu = $"Control/PauseMenu"
@onready var elevator_panel = $"Control/ElevatorPanel"
@onready var inventory = $"Control/Inventory"
@onready var toolbar = $"Control/Toolbar"
@onready var chest = $"Control/Chest"

signal on_closed_menu

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	toolbar.activate()

func _input(event : InputEvent):
	if event.is_action_pressed("menu"):
		if submenu_active:
			if (cur_menu != pause_menu and cur_menu != inventory):
				on_closed_menu.emit()
			cur_menu.deactivate()
			submenu_active = false
		else:
			submenu_active = true
			cur_menu = pause_menu
			pause_menu.activate()
	elif event.is_action_pressed("inv"):
		if submenu_active:
			if (cur_menu == inventory or cur_menu == chest):
				if cur_menu != inventory:
					on_closed_menu.emit()
				cur_menu.deactivate()
				submenu_active = false
		else:
			submenu_active = true
			cur_menu = inventory
			inventory.activate(null)

func elevator_panel_open(elevator_id):
	submenu_active = true
	cur_menu = elevator_panel
	elevator_panel.activate(elevator_id)
