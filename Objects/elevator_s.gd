extends StaticBody2D

@export var elevator_tag : String
@export var spawn_direction : String

@onready var animation_player = $AnimationPlayer
@onready var collision = $CollisionShape2D
@onready var blackout = $Black
@onready var spawn = $Spawn

var state : String = "opened"
var busy : bool = false
var mutex : Mutex
var elev_id : int

func _ready():
	if (elevator_tag == "R"):
		elev_id = 1
	else:
		elev_id = 0
	mutex = Mutex.new()
	collision.disabled = true
	blackout.visible = false
	animation_player.play("opened")

func open():
	mutex.lock()
	if state == "closed":
		state = "opening"
		animation_player.play("open")
	elif state == "closing":
		state = "opening"
		var pos = animation_player.get_current_animation_position()
		animation_player.play("open")
		animation_player.seek(animation_player.get_current_animation_length() - pos)
	mutex.unlock()

func close():
	mutex.lock()
	if state == "opened":
		if busy:
			ElevatorManager.closed_elevator(elev_id, false)
		else:
			state = "closing"
			animation_player.play("close")
	mutex.unlock()

func open_entered():
	mutex.lock()
	busy = true
	if state == "closing":
		state = "opening"
		var pos = animation_player.get_current_animation_position()
		animation_player.play("open")
		animation_player.seek(animation_player.get_current_animation_length() - pos)
		ElevatorManager.closed_elevator(elev_id, false)
	elif state == "open":
		ElevatorManager.closed_elevator(elev_id, false)
	mutex.unlock()

func close_entered():
	mutex.lock()
	busy = false
	mutex.unlock()

func _on_animation_player_animation_finished(anim_name):
	mutex.lock()
	if anim_name == "open":
		state = "opened"
		collision.disabled = true
		blackout.visible = false
		animation_player.play("opened")
	elif anim_name == "close":
		state = "closed"
		collision.disabled = false
		blackout.visible = true
		animation_player.play("closed")
		ElevatorManager.closed_elevator(elev_id, true)
	mutex.unlock()

func transfer():
	NavigationManager.call_deferred("go_to_level",
			"floor_" + str(ElevatorManager.elevators[elev_id].floor_id),
			elevator_tag)
