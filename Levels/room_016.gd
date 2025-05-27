extends Node2D

func _ready():
	if NavigationManager.spawn_door_tag != null:
		_on_level_spawn(NavigationManager.spawn_door_tag)

func _on_level_spawn(destination_tag: String):
	var transf = get_node("Door" + destination_tag)
	transf.set_open()
	NavigationManager.trigger_player_spawn(transf.spawn.global_position, transf.spawn_direction)
