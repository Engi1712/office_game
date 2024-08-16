extends Node2D

@onready var elevator = $ElevatorS
@onready var ui = $UI
@onready var floor_sign = $ElevatorPanel/Indicator

var elevator_id = 0

func _ready():
	ElevatorManager.on_elevator_open.connect(_on_open)
	ElevatorManager.on_elevator_floor.connect(_on_floor)
	ElevatorManager.on_elevator_close.connect(_on_close)
	floor_sign.frame = ElevatorManager.elevators[elevator_id].floor_id
	_on_level_spawn()

func _on_open(id):
	if elevator_id == id:
		elevator.open()

func _on_floor(id, cur_floor):
	if elevator_id == id:
		floor_sign.frame = cur_floor

func _on_close(id):
	if elevator_id == id:
		elevator.close()

func _on_elevator_panel_activate():
	ui.elevator_panel_toggle(elevator_id)

func _on_level_spawn():
	NavigationManager.trigger_player_spawn(elevator.spawn.global_position, elevator.spawn_direction)
