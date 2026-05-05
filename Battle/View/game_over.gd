extends Control

@onready var message = $PanelContainer/MarginContainer/Message

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
