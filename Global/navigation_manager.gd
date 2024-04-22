extends Node

const scene_it_dep = preload("res://Levels/it_dep.tscn")
const scene_it_room = preload("res://Levels/it_room.tscn")

signal on_triggered_player_spawn

var spawn_door_tag

func go_to_level(level_tag, destination_tag):
	var scene_to_load
	
	match level_tag:
		"it_dep" :
			scene_to_load = scene_it_dep
		"it_room" :
			scene_to_load = scene_it_room
	
	if scene_to_load != null:
		spawn_door_tag = destination_tag
		get_tree().change_scene_to_packed(scene_to_load)

func trigger_player_spawn(position : Vector2, direction : String ):
	on_triggered_player_spawn.emit(position, direction)
