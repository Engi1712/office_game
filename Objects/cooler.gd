extends StaticBody2D

@export var is_filled : bool = false

@onready var animation_tree = $AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")

func _physics_process(_delta):
	pick_new_state()

func pick_new_state():
	if (is_filled):
		state_machine.travel("fill")
	else:
		state_machine.travel("idle")
