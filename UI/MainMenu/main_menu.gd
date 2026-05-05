extends Control

@onready var main_submenu = $VBoxContainer/Main
@onready var remote_submenu = $VBoxContainer/RemotePVP

func _ready():
	var submenu = MenuSwitcher.get_param("submenu")
	var initial = MenuSwitcher.get_param("initial")
	if submenu == "remote":
		main_submenu.hide()
		remote_submenu.show()
	else:
		main_submenu.show()
		remote_submenu.hide()
	if Glob.is_debug:
		if !initial:
			get_tree().quit()
		match Glob.debug_options.cur_part:
			DebugOptions.parts.MAIN:
				show()
			DebugOptions.parts.BATTLE:
				match Glob.debug_options.battle_jump_in_place:
					DebugOptions.battle_jump_in.HOT_SEAT:
						MenuSwitcher.switch("battle", \
								{"mode": BattleCommon.modes.HOT_SEAT, \
								"lower_player": "john_doe", \
								"upper_player": "joe_shmoe"})
					DebugOptions.battle_jump_in.BOT:
						MenuSwitcher.switch("battle", \
								{"mode": BattleCommon.modes.BOT, \
								"lower_player": "john_doe", \
								"upper_player": "joe_shmoe"})
					DebugOptions.battle_jump_in.NONE:
						show()
	else:
		show()

func _on_hot_seat_button_pressed():
	MenuSwitcher.switch("player_preparation", \
			{"mode": BattleCommon.modes.HOT_SEAT, \
			"player_id": 0})

func _on_exit_button_pressed():
	get_tree().quit()

func _on_remote_button_pressed():
	main_submenu.hide()
	remote_submenu.show()

func _on_back_button_pressed():
	main_submenu.show()
	remote_submenu.hide()

func _on_join_button_pressed():
	MenuSwitcher.switch("multiplayer_menu", \
			{"mode": BattleCommon.modes.HOT_SEAT, \
			"lobby_mode": "join"})

func _on_host_button_pressed():
	MenuSwitcher.switch("multiplayer_menu", \
			{"mode": BattleCommon.modes.HOT_SEAT, \
			"lobby_mode": "host"})
