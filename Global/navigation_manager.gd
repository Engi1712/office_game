extends Node

const scene_floor_0 = preload("res://Levels/floor_0.tscn")
const scene_floor_1 = preload("res://Levels/floor_1.tscn")
const scene_floor_2 = preload("res://Levels/floor_2.tscn")
const scene_room_2_rest = preload("res://Levels/room_2_rest.tscn")
const scene_room_209 = preload("res://Levels/room_209.tscn")
const scene_elevator_l = preload("res://Levels/elevator_l.tscn")

signal on_triggered_player_spawn

var spawn_door_tag

func go_to_level(level_tag, destination_tag):
	var scene_to_load
	
	match level_tag:
		"floor_0" :
			scene_to_load = scene_floor_0
		"floor_1" :
			scene_to_load = scene_floor_1
		"floor_2" :
			scene_to_load = scene_floor_2
		"room_2_rest" :
			scene_to_load = scene_room_2_rest
		"room_209" :
			scene_to_load = scene_room_209
		"elevator_l" :
			scene_to_load = scene_elevator_l
	
	if scene_to_load != null:
		TransitionScreen.transition()
		await TransitionScreen.on_transition_finished
		spawn_door_tag = destination_tag
		get_tree().change_scene_to_packed(scene_to_load)

func trigger_player_spawn(position : Vector2, direction : String ):
	on_triggered_player_spawn.emit(position, direction)
