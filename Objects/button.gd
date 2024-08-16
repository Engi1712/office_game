extends Node2D

@onready var sprite = $Sprite2D

var state = "off"
var mutex : Mutex

signal on_elevator_called

func _ready():
	mutex = Mutex.new()

func touch():
	mutex.lock()
	if state == "off":
		state = "on"
		sprite.frame = 1
		on_elevator_called.emit()
	mutex.unlock()

func release():
	pass

func approach():
	pass

func leave():
	pass

func off():
	mutex.lock()
	if state == "on":
		state = "off"
		sprite.frame = 0
	mutex.unlock()
