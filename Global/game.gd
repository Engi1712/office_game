extends Node

@export var current_scale: int = 1

signal on_translation_updated

var resolution = Vector2(640, 360)

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
		current_scale = 2
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		get_window().borderless = true
		current_scale = min(get_window().get_size_with_decorations().x / resolution.x,
				get_window().get_size_with_decorations().y / resolution.y)
	var arrow = load("res://Art/Office Pack/HUD/cursor" + str(current_scale) + ".png")
	Input.set_custom_mouse_cursor(arrow)
	TranslationServer.set_locale("ru")
	on_translation_updated.emit()
	NavigationManager.call_deferred("go_to_level", "floor_2", "202")
