extends Node2D

func _ready():
	if NavigationManager.spawn_door_tag != null:
		_on_level_spawn(NavigationManager.spawn_door_tag)

func _on_level_spawn(destination_tag: String):
	var transf : TransferArea
	if destination_tag == "L" or destination_tag == "R":
		transf = get_node("ElevatorsN/Elevator" + destination_tag + "/TransferArea")
	else:
		get_node("Doors/Door" + destination_tag).set_open()
		transf = get_node("Doors/Door" + destination_tag + "/TransferArea")
	NavigationManager.trigger_player_spawn(transf.spawn.global_position, transf.spawn_direction)
