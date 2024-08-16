extends Node2D

@export var current : int

@onready var sprite = $Sprite2D

func _ready():
	current = 1
	set_sprite()

func set_current(val):
	current = val
	set_sprite()

func set_sprite():
	sprite.frame = current
