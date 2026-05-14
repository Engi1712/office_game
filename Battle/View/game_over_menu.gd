class_name GameOverMenu extends Control

signal new_game_button_pressed
signal exit_button_pressed

@onready var message = $PanelContainer/MarginContainer/VBoxContainer/PanelContainer/Message

var opened: bool

func _ready():
	close()

func open(winners: Array[SystemCore], mode: BattleCommon.modes):
	if winners.size() != 1:
		message.text = "DRAW"
	else:
		if mode == BattleCommon.modes.BOT or mode == BattleCommon.modes.STEAM:
			if winners[0].view.is_interactible():
				message.text = "VICTORY!"
			else:
				message.text = "DEFEAT..."
		else:
			message.text = winners[0].view.system_name + " WINS"
	opened = true
	show()

func close():
	opened = false
	hide()

func is_opened():
	return opened

func _on_new_game_pressed():
	new_game_button_pressed.emit()

func _on_exit_pressed():
	exit_button_pressed.emit()
