extends StaticBody2D

@export var elevator_tag : String
@export var spawn_direction : String

@onready var animation_player = $AnimationPlayer
@onready var collision = $CollisionShape2D
@onready var indicator = $Indicator
@onready var spawn = $Spawn

var state : String = "closed"
var busy : bool = false
var mutex : Mutex
var elev_id : int
var destination_level_tag : String = "elevator_"

func _ready():
	if (elevator_tag == "R"):
		elev_id = 1
		destination_level_tag += "r"
	else:
		elev_id = 0
		destination_level_tag += "l"
	mutex = Mutex.new()
	animation_player.play("closed")

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

func set_floor(floor_id):
	if floor_id >= 0 and floor_id <= 10:
		indicator.set_current(floor_id + 1)
	elif floor_id <= -1 and floor_id >= -3:
		indicator.set_current(11 - floor_id)
	else:
		indicator.set_current(15)

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
		animation_player.play("opened")
	elif anim_name == "close":
		state = "closed"
		collision.disabled = false
		animation_player.play("closed")
		ElevatorManager.closed_elevator(elev_id, true)
	mutex.unlock()

func transfer():
	NavigationManager.call_deferred("go_to_level", destination_level_tag, "")
