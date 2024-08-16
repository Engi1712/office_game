extends StaticBody2D

@export var destination_level_tag : String
@export var destination_door_tag : String
@export var spawn_direction : String

@onready var animation_player = $AnimationPlayer
@onready var collision = $CollisionShape2D
@onready var spawn = $Spawn

var state : String = "close"
var mutex : Mutex

func _ready():
	collision.set_deferred("disabled", false)
	mutex = Mutex.new()
	animation_player.play("close")

func touch():
	pass

func release():
	pass

func approach():
	mutex.lock()
	if state == "closing":
		state = "opening"
		var pos = animation_player.get_current_animation_position()
		animation_player.play("opening")
		animation_player.seek(animation_player.get_current_animation_length() - pos)
		collision.set_deferred("disabled", true)
	elif state == "close":
		state = "opening"
		animation_player.play("opening")
		collision.set_deferred("disabled", true)
	mutex.unlock()

func leave():
	mutex.lock()
	if state == "opening":
		state = "closing"
		var pos = animation_player.get_current_animation_position()
		animation_player.play("closing")
		animation_player.seek(animation_player.get_current_animation_length() - pos)
	elif state == "open":
		state = "closing"
		animation_player.play("closing")
	mutex.unlock()

func set_open():
	mutex.lock()
	state = "open"
	animation_player.play("open")
	collision.set_deferred("disabled", true)
	mutex.unlock()

func _on_animation_player_animation_finished(anim_name):
	mutex.lock()
	if anim_name == "opening":
		state = "open"
		animation_player.play("open")
	elif anim_name == "closing":
		state = "close"
		animation_player.play("close")
		collision.set_deferred("disabled", false)
	mutex.unlock()

func transfer():
	NavigationManager.call_deferred("go_to_level", destination_level_tag, destination_door_tag)
