class_name ScriptFile extends Control

@onready var name_label = $MarginContainer/VBoxContainer/Name
@onready var specs_label = $MarginContainer/VBoxContainer/Specs
@onready var turns_label = $MarginContainer/VBoxContainer/Turns
@onready var price_label = $MarginContainer/VBoxContainer/Price
@onready var traffic_label = $MarginContainer/VBoxContainer/Traffic
@onready var load_space = $MarginContainer/VBoxContainer/Load
@onready var animation = $SubViewportContainer/SubViewport/Sprite2D
@onready var animation_player = $SubViewportContainer/SubViewport/AnimationPlayer
@onready var default_bg = $DefaultBG
@onready var hover_bg = $HoverBG
@onready var select_bg = $SelectBG

var can_afford: bool = false

var tooltip: Tooltip

var model: ScriptFileCore

func _ready():
	idle()

# --- Public ---

func update():
	set_script_name()
	set_script_specs()
	if model.item_type == BattleCommonCore.item_types.RAM_SCRIPT:
		set_script_turns()
		set_script_load()
		set_script_traffic()
	if model.item_type == BattleCommonCore.item_types.SHOP_SCRIPT:
		default_bg.visible = false
		set_script_price()
	tooltip.update()

func highlight():
	animation.visible = true
	animation_player.play("highlight")

func idle():
	animation_player.play("idle")
	animation.visible = false

func hover():
	hover_bg.visible = true

func dehover():
	hover_bg.visible = false

func select():
	select_bg.visible = true

func deselect():
	select_bg.visible = false

# --- Private ---

func set_script_name():
	var display_script_name: String = ""
	display_script_name += \
			"[img]res://Art/Office Pack/Battle/Icons/Directions/" + \
			BattleCommon.get_line_script_direction(model.direction) + ".png[/img] " + \
			"[img]res://Art/Office Pack/Battle/Icons/Types/" + \
			BattleCommon.get_line_script_type(model.type) + ".png[/img] " + \
			model.script_name + ".sh"
	if model.available:
		name_label.text = display_script_name
	else:
		name_label.text = "[color=" + ColourPalette.red + "]" + display_script_name + "[/color]"

func set_script_specs():
	var display_script_specs: String = ""
	if model.copy_price != 0:
		display_script_specs += get_price_str(BattleCommonCore.price_types.COPY)
	if model.delete_price != 0:
		display_script_specs += get_price_str(BattleCommonCore.price_types.DELETE)
	if model.run_price != 0:
		display_script_specs += get_price_str(BattleCommonCore.price_types.RUN)
	if model.stop_price != 0:
		display_script_specs += get_price_str(BattleCommonCore.price_types.STOP)
	specs_label.text = display_script_specs

func set_script_turns():
	if model.turns_to_live == 0:
		return
	turns_label.text = "[color=" + ColourPalette.grey + "]turns left: " + str(model.turns_left) + \
			"/" + str(model.turns_to_live) + "[/color]"
	turns_label.visible = true

func set_script_price():
	var display_script_price: String = ""
	display_script_price += "[img]res://Art/Office Pack/Battle/Icons/Tokens/taucoin.png[/img] "
	if can_afford:
		display_script_price += str(model.shop_price)
	else:
		display_script_price += "[color=" + ColourPalette.red + "]" + str(model.shop_price) + "[/color]"
	price_label.text = display_script_price
	price_label.visible = true

func set_script_load():
	for i in range(model.cpus.size()):
		var spc: BattleCommonCore.script_per_cpu = model.cpus[i]
		var display_script_load: String = ""
		var label = load_space.get_node("CPU" + str(i + 1))
		if !spc.selected:
			if label:
				load_space.remove_child(label)
				label.queue_free()
			continue
		if !label:
			label = RichTextLabel.new()
			label.name = "CPU" + str(i + 1)
			label.bbcode_enabled = true
			label.fit_content = true
			load_space.add_child(label)
		display_script_load += "[color=" + ColourPalette.grey + "]CPU " + str(spc.cpu_node.id + 1)
		if spc.cpu_node.is_vm:
			display_script_load += "v"
		if spc.max_load != 0:
			display_script_load += ": " + str(spc.cur_load) + "/" + str(spc.max_load) + \
					TranslationServer.translate("BATTLE_CPU_UNIT") + "[/color]"
		label.text = display_script_load
	load_space.visible = true

func set_script_traffic():
	if model.traffic_total == 0:
		return
	traffic_label.text = "[color=" + ColourPalette.grey + "]traffic left: " + str(model.traffic_left) + \
			"/" + str(model.traffic_total) + "[/color]"
	traffic_label.visible = true

func get_price_str(price_type: BattleCommonCore.price_types):
	var price_str: String
	var action: String
	var price_deviation: int
	
	match price_type:
		BattleCommonCore.price_types.COPY:
			action = "copy"
		BattleCommonCore.price_types.DELETE:
			action = "delete"
		BattleCommonCore.price_types.RUN:
			action = "run"
		BattleCommonCore.price_types.STOP:
			action = "stop"
	
	price_str = "[img]res://Art/Office Pack/Battle/Icons/Actions/" + action + ".png[/img] "
	price_deviation = model.get_cur_price_deviation(price_type)
	if price_deviation > 0:
		price_str += "[color=" + ColourPalette.red + "]" + str(model.get_cur_price(price_type)) + "[/color] "
	elif price_deviation < 0:
		price_str += "[color=" + ColourPalette.green + "]" + str(model.get_cur_price(price_type)) + "[/color] "
	else:
		price_str += str(model.get_cur_price(price_type)) + " "
	return price_str
