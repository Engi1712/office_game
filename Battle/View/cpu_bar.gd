class_name CPUBar extends Control

@onready var label = $MarginContainer/RichTextLabel
@onready var animation = $SubViewportContainer/SubViewport/Sprite2D
@onready var animation_player = $SubViewportContainer/SubViewport/AnimationPlayer

var available: bool = true

var load_step: int = 10
var load_percent_red: int = 70
var load_percent_yellow: int = 40
var max_digits_load: int = 3

var tooltip: Tooltip

var model: CPUBarCore

func _ready():
	idle()

# --- Public ---

func update():
	var prefix = get_id_icon() + get_bounty_icon()
	
	if model.status == BattleCommonCore.cpu_states.WAITING:
		visible = false
	else:
		visible = true
		if model.status == BattleCommonCore.cpu_states.BROKEN:
			label.text = prefix + get_broken_line()
		else:
			label.text = prefix + get_load_line(model.max_load, model.cur_load)
	tooltip.update()

func set_available():
	available = true

func set_unavailable():
	available = false

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

# --- Private ---

func get_id_icon():
	var cpu_id: String
	if model.is_vm:
		cpu_id = "v"
	else:
		cpu_id = str(model.id + 1)
	if !model.modifiers.is_empty():
		cpu_id += "_safe"
	return "[img]res://Art/Office Pack/Battle/Icons/MISC/CPU/cpu_" + cpu_id + ".png[/img]"

func get_bounty_icon():
	var cur_bounty: String
	match model.bounty:
		BattleCommonCore.bounty_types.NONE:
			cur_bounty = "none"
		BattleCommonCore.bounty_types.HIGH:
			cur_bounty = "high"
		BattleCommonCore.bounty_types.LOW:
			cur_bounty = "low"
	return "[img]res://Art/Office Pack/Battle/Icons/MISC/Bounty/bounty_" + cur_bounty + ".png[/img]"

func get_load_preceed(p_load: int):
	var digits = str(p_load).length()
	if digits > max_digits_load:
		return "???"
	return ("  ".repeat(max_digits_load - digits)) + str(p_load)

func get_load_line(max_load: int, cur_load: int):
	var bars: String = ""
	var bars_colour: String
	var brackets_colour: String
	
	for i in range(max_load / load_step):
		bars += " "
		if cur_load > i * load_step:
			bars += "|"
		else:
			bars += "."
	if available:
		if cur_load > (load_percent_red / 100.0) * max_load:
			bars_colour = ColourPalette.red
		elif cur_load > (load_percent_yellow / 100.0) * max_load:
			bars_colour = ColourPalette.yellow
		else:
			bars_colour = ColourPalette.green
		brackets_colour = ColourPalette.white
	else:
		bars_colour = ColourPalette.grey
		brackets_colour = ColourPalette.grey
	
	return "[color=" + brackets_colour + "][[/color]" + \
			"[color=" + bars_colour + "]"+ bars + "\t" + get_load_preceed(cur_load) + \
			TranslationServer.translate("BATTLE_CPU_UNIT") + "[/color]" + \
			"[color=" + brackets_colour + "]][/color]"

func get_broken_line():
	var line = "    B R O K E N    "
	if available:
		line = "[color=" + ColourPalette.red + "]" + line + "[/color]"
	line = "[" + line + "]"
	if !available:
		line = "[color=" + ColourPalette.grey + "]" + line + "[/color]"
	return line
