class_name TransferArea extends Area2D

@onready var object = get_parent()

func _on_body_entered(body):
	if body is CharacterBody2D:
		object.transfer()
