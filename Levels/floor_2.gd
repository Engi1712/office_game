extends Node2D

func _ready():
	if NavigationManager.spawn_door_tag != null:
		_on_level_spawn(NavigationManager.spawn_door_tag)

func _on_level_spawn(destination_tag: String):
	if destination_tag == "L" or destination_tag == "R":
		var transf = get_node("ElevatorsN/Elevator" + destination_tag)
		NavigationManager.trigger_player_spawn(transf.spawn.global_position, transf.spawn_direction)
	else:
		var transf = get_node("Doors/Door" + destination_tag)
		transf.set_open()
		NavigationManager.trigger_player_spawn(transf.spawn.global_position, transf.spawn_direction)
