class_name ItemSpace extends Control

@onready var items = $Files/VBoxContainer
@onready var animation = $SubViewportContainer
@onready var animation_player = $SubViewportContainer/SubViewport/AnimationPlayer

func get_items():
	return items.get_children()

func add_item(item: Node):
	items.add_child(item)

func remove_item(item: Node):
	items.remove_child(item)

func highlight():
	animation.visible = true
	animation_player.play("highlight")

func idle():
	animation_player.play("idle")
	animation.visible = false
