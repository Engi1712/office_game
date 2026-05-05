class_name NetInterface extends Control

@onready var name_label = $MarginContainer/HBoxContainer/Name
@onready var traffic_label = $MarginContainer/HBoxContainer/Traffic
@onready var animation = $SubViewportContainer/SubViewport/Sprite2D
@onready var animation_player = $SubViewportContainer/SubViewport/AnimationPlayer

var traffic_percent_red: int = 70
var traffic_percent_yellow: int = 40

var tooltip: Tooltip

var model: NetInterfaceCore

func _ready():
	idle()

# --- Public ---

func update():
	name_label.text = model.iface_name + str(model.id + 1)
	var colour: String
	if model.cur_traffic > traffic_percent_red:
		colour = ColourPalette.red
	elif model.cur_traffic > traffic_percent_yellow:
		colour = ColourPalette.yellow
	else:
		colour = ColourPalette.green
	traffic_label.text = "[color=" + colour + "]"+ str(model.cur_traffic) + \
			TranslationServer.translate("BATTLE_NETWORK_UNIT") + "[/color]"
	tooltip.update()

func highlight():
	animation.visible = true
	animation_player.play("highlight")

func idle():
	animation_player.play("idle")
	animation.visible = false

func hover():
	pass

func dehover():
	pass
