extends Node

@onready var main = $Main

func _ready():
	#var is_debug = false
	#if is_debug:
		#var window_size = Vector2(1280, 720)
		#var screen_size = DisplayServer.screen_get_size()
		#var centered = Vector2(screen_size.x / 2 - window_size.x / 2, screen_size.y / 2 - window_size.y / 2)
		#DisplayServer.window_set_size(window_size)
		#DisplayServer.window_set_position(centered)
		#Glob.current_scale = 2
	#else:
		#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		#get_window().borderless = true
		#Glob.current_scale = min(get_window().get_size_with_decorations().x / Glob.resolution.x,
				#get_window().get_size_with_decorations().y / Glob.resolution.y)
	#var arrow = load("res://Art/Office Pack/HUD/Cursors/cursor" + str(Glob.current_scale) + ".png")
	#Input.set_custom_mouse_cursor(arrow)
	#TranslationServer.set_locale("ru")
	#Glob.on_translation_updated.emit()
	main.run_level()
