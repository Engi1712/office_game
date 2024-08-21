extends StaticBody2D

@onready var animation_player = $AnimationPlayer
@onready var ui = get_node("../UI")

var state : String = "close"
var mutex : Mutex

func _ready():
	mutex = Mutex.new()
	ui.on_closed_menu.connect(leave)
	animation_player.play("close")

func touch():
	mutex.lock()
	match state:
		"open" :
			ui.chest_close()
			state = "closing"
			animation_player.play("closing")
		"close" :
			state = "opening"
			animation_player.play("opening")
		"opening" :
			ui.chest_close()
			state = "closing"
			var pos = animation_player.get_current_animation_position()
			animation_player.play("closing")
			animation_player.seek(animation_player.get_current_animation_length() - pos)
		"closing" :
			state = "opening"
			var pos = animation_player.get_current_animation_position()
			animation_player.play("opening")
			animation_player.seek(animation_player.get_current_animation_length() - pos)
	mutex.unlock()

func release():
	pass

func approach():
	pass

func leave():
	mutex.lock()
	match state:
		"open" :
			ui.chest_close()
			state = "closing"
			animation_player.play("closing")
		"opening" :
			ui.chest_close()
			state = "closing"
	mutex.unlock()

func _on_animation_player_animation_finished(anim_name):
	mutex.lock()
	if anim_name == "opening":
		state = "open"
		animation_player.play("open")
		ui.chest_open()
	if anim_name == "closing":
		state = "close"
		animation_player.play("close")
	mutex.unlock()
