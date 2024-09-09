extends Node

func _ready():
	var is_debug = true
	if is_debug:
		#var window_size = Vector2(1920, 1080)
		var window_size = Vector2(1280, 720)
		#var window_size = Vector2(640, 360)
		var screen_size = DisplayServer.screen_get_size()
		var centered = Vector2(screen_size.x / 2 - window_size.x / 2 + screen_size.x, screen_size.y / 2 - window_size.y / 2)
		#DisplayServer.window_set_current_screen(2)
		DisplayServer.window_set_size(window_size)
		DisplayServer.window_set_position(centered)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		get_window().borderless = true
		print(get_window().get_size_with_decorations())
		print(get_window().borderless)
	NavigationManager.call_deferred("go_to_level", "floor_2", "202")
