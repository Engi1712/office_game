extends StaticBody2D

@export var is_open : bool = false

@onready var animation_tree = $AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")

var state : String = "closed"

func _physics_process(_delta):
	pick_new_state()

func pick_new_state():
	if state == "opened" and is_open == false:
		state = "closing"
		state_machine.travel("close")
	elif state == "closed" and is_open == true:
		state = "opening"
		state_machine.travel("open")

func _on_animation_tree_animation_finished(anim_name):
	if anim_name == "open":
		state = "opened"
	elif anim_name == "close":
		state = "closed"
