extends Node

func run_level():
	#NavigationManager.trigger_player_spawn(Vector2(0, 0), "down")
	NavigationManager.call_deferred("go_to_level", "floor_0", "Main")
