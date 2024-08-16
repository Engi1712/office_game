extends StaticBody2D

@onready var animation_player = $AnimationPlayer

var state : String = "fill"

func _ready():
	animation_player.play("idle")
	
func touch():
	if state == "idle":
		state = "fill"
		animation_player.play("fill")

func release():
	if state == "fill":
		state = "idle"
		animation_player.play("idle")

func approach():
	pass

func leave():
	if state == "fill":
		state = "idle"
		animation_player.play("idle")
