extends Node2D

@export var floor_id = ""

@onready var elevator_left = $ElevatorL
@onready var elevator_right = $ElevatorR
@onready var button = $Button
@onready var floor_sign = $FloorSign

func _ready():
	ElevatorManager.on_elevator_open.connect(_on_open)
	ElevatorManager.on_elevator_floor.connect(_on_floor)
	ElevatorManager.on_elevator_close.connect(_on_close)
	floor_sign.frame = int(floor_id)
	elevator_left.set_floor(ElevatorManager.elevators[0].floor_id)
	elevator_right.set_floor(ElevatorManager.elevators[1].floor_id)

func _on_button_on_elevator_called():
	ElevatorManager.call_elevator(int(floor_id))

func _on_open(id):
	match id:
		0:
			elevator_left.open()
			button.off()
		1:
			elevator_right.open()
			button.off()

func _on_floor(id, cur_floor):
	match id:
		0:
			elevator_left.set_floor(cur_floor)
		1:
			elevator_right.set_floor(cur_floor)

func _on_close(id):
	match id:
		0:
			elevator_left.close()
		1:
			elevator_right.close()
