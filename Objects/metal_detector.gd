extends StaticBody2D

@onready var sprite = $Sprite2D

func approach(_area_type: String):
	sprite.frame = 1

func leave(_area_type: String):
	sprite.frame = 0
