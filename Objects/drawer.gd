extends StaticBody2D

@export var inv_res: String = ""

@onready var animation_player = $AnimationPlayer

var state: String = "close"
var mutex: Mutex
var inv_list: InvList

func _ready():
	mutex = Mutex.new()
	UI.on_closed_menu.connect(leave)
	inv_list = load("res://GameData/Inventories/" + inv_res + ".tres")
	animation_player.play("close")

func touch():
	mutex.lock()
	match state:
		"open" :
			UI.chest.deactivate()
			state = "closing"
			animation_player.play("closing")
		"close" :
			state = "opening"
			animation_player.play("opening")
		"opening" :
			UI.chest.deactivate()
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
			UI.chest.deactivate()
			state = "closing"
			animation_player.play("closing")
		"opening" :
			UI.chest.deactivate()
			state = "closing"
	mutex.unlock()

func _on_animation_player_animation_finished(anim_name):
	mutex.lock()
	if anim_name == "opening":
		state = "open"
		animation_player.play("open")
		UI.chest.activate(inv_list)
	if anim_name == "closing":
		state = "close"
		animation_player.play("close")
	mutex.unlock()
