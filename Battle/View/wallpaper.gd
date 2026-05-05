class_name Wallpaper extends SubViewportContainer

@onready var wallpapers = $SubViewport

var cur_wallpaper = null
var cur_animation = null

func set_wallpaper(wallpaper_name: String):
	cur_wallpaper = wallpapers.get_node(wallpaper_name)
	cur_wallpaper.visible = true
	cur_animation = cur_wallpaper.get_node("AnimationPlayer")
	cur_animation.play("play")

func resume():
	cur_animation.play()

func pause():
	cur_animation.pause()
