class_name Tooltip extends PanelContainer

@onready var cpu_container = $CPU
@onready var cpu_name_label = $CPU/Name
@onready var cpu_load_label = $CPU/Load
@onready var cpu_modifiers_label = $CPU/Modifiers
@onready var cpu_modifier_list = $CPU/ModifierList

@onready var script_container = $Script
@onready var script_name_label = $Script/Name
@onready var script_direction_label = $Script/Direction
@onready var script_type_label = $Script/Type
@onready var script_description_label = $Script/Description
@onready var script_temporary_label = $Script/Temporary
@onready var script_auto_deleted_label = $Script/AutoDeleted
@onready var script_copy_price_label = $Script/CopyPrice
@onready var script_delete_price_label = $Script/DeletePrice
@onready var script_run_price_label = $Script/RunPrice
@onready var script_stop_price_label = $Script/StopPrice
@onready var script_load_list = $Script/Load
@onready var script_load_header_label = $Script/Load/Header
@onready var script_load_cpus_list = $Script/Load/CPUs
@onready var script_modifiers_list = $Script/Modifiers
@onready var script_modifiers_header_label = $Script/Modifiers/Header
@onready var script_modifiers_cpus_list = $Script/Modifiers/CPUs
@onready var script_traffic_list = $Script/Traffic
@onready var script_traffic_header_label = $Script/Traffic
@onready var script_traffic_ifaces_local_list = $Script/Traffic/Ifaces/Local
@onready var script_traffic_ifaces_remote_list = $Script/Traffic/Ifaces/Remote

@onready var iface_container = $Iface
@onready var iface_name_label = $Iface/Name
@onready var iface_traffic_label = $Iface/Traffic

@onready var token_container = $Token

@onready var containers = [cpu_container, script_container, token_container, iface_container]

var type: BattleCommon.tooltip_types
var parent_node: Control
var upper: bool

var header_colour = ColourPalette.light_yellow

func _init():
	make_transparent()

func _ready():
	set_script_visibility()
	prepare()

func _input(event: InputEvent):
	if !visible or event is not InputEventMouseMotion:
		return
	update_position()

# --- Public ---

# View

func update():
	match type:
		BattleCommon.tooltip_types.CPU:
			update_cpu(parent_node.model)
		BattleCommon.tooltip_types.SCRIPT:
			update_script(parent_node.model)
		BattleCommon.tooltip_types.IFACE:
			update_iface(parent_node.model)
		BattleCommon.tooltip_types.TOKEN:
			update_token(parent_node as RichTextLabel)

func update_position():
	var new_pos: Vector2
	if upper:
		new_pos = get_global_mouse_position() + Vector2(12, -size.y)
		if new_pos.y < 2:
			new_pos.y = 2
	else:
		new_pos = get_global_mouse_position() + Vector2(12, 17)
		var diff_y = Glob.resolution.y - 2 - new_pos.y - size.y
		if diff_y < 0:
			new_pos.y += diff_y
	var diff_x = Glob.resolution.x - new_pos.x - size.x
	if diff_x < 0:
		new_pos.x += diff_x
	global_position = new_pos
	reset_size()

func make_transparent():
	self.modulate = Color(1, 1, 1, 0)

func make_opaque():
	self.modulate = Color(1, 1, 1, 1)

# --- Private ---

func prepare():
	match type:
		BattleCommon.tooltip_types.CPU:
			prepare_cpu(parent_node.model)
		BattleCommon.tooltip_types.SCRIPT:
			prepare_script(parent_node.model)
		BattleCommon.tooltip_types.IFACE:
			prepare_iface(parent_node.model)
		BattleCommon.tooltip_types.TOKEN:
			prepare_token(parent_node as RichTextLabel)

func prepare_cpu(cpu_node: CPUBarCore):
	prepare_cpu_modifiers(cpu_node)
	set_cpu_name(cpu_node)

func prepare_script(script_file: ScriptFileCore):
	prepare_script_load(script_file)
	prepare_script_modifiers(script_file)
	prepare_script_traffic(script_file)
	set_script_name(script_file)
	set_script_direction(script_file)
	set_script_type(script_file)
	set_script_description(script_file)
	set_script_temporary(script_file)
	set_script_auto_deleted(script_file)
	set_script_prices(script_file)

func prepare_iface(iface: NetInterfaceCore):
	set_iface_name(iface)

func prepare_token(_token: RichTextLabel):
	pass

func update_cpu(cpu: CPUBarCore):
	set_cpu_load(cpu)
	set_cpu_modifiers(cpu)

func update_script(script_file: ScriptFileCore):
	set_script_description(script_file)
	set_script_prices(script_file)
	set_script_load(script_file)
	set_script_modifiers(script_file)
	set_script_traffic(script_file)

func update_iface(iface: NetInterfaceCore):
	set_iface_traffic(iface)

func update_token(_token: RichTextLabel):
	pass

# Script

func set_script_visibility():
	for i in containers:
		i.visible = false
	cpu_load_label.visible = false
	cpu_modifiers_label.visible = false
	cpu_modifier_list.visible = false
	script_name_label.visible = false
	script_direction_label.visible = false
	script_type_label.visible = false
	script_description_label.visible = false
	script_temporary_label.visible = false
	script_auto_deleted_label.visible = false
	script_copy_price_label.visible = false
	script_delete_price_label.visible = false
	script_run_price_label.visible = false
	script_stop_price_label.visible = false
	script_load_list.visible = false
	script_modifiers_list.visible = false
	script_traffic_list.visible = false
	iface_name_label.visible = false
	iface_traffic_label.visible = false
	match type:
		BattleCommon.tooltip_types.CPU:
			cpu_container.visible = true
		BattleCommon.tooltip_types.SCRIPT:
			script_container.visible = true
		BattleCommon.tooltip_types.TOKEN:
			token_container.visible = true
		BattleCommon.tooltip_types.IFACE:
			iface_container.visible = true

func set_script_name(script_file: ScriptFileCore):
	script_name_label.text = "[color=" + header_colour + "]" + script_file.script_name + ".sh[/color]"
	script_name_label.visible = true

func set_script_direction(script_file: ScriptFileCore):
	script_direction_label.text = "[img]res://Art/Office Pack/Battle/Icons/Directions/" + \
			BattleCommon.get_line_script_direction(script_file.direction) + ".png[/img] " + \
			BattleCommon.get_line_script_direction(script_file.direction)
	script_direction_label.visible = true

func set_script_type(script_file: ScriptFileCore):
	script_type_label.text = "[img]res://Art/Office Pack/Battle/Icons/Types/" + \
			BattleCommon.get_line_script_type(script_file.type) + ".png[/img] " + \
			BattleCommon.get_line_script_type(script_file.type)
	script_type_label.visible = true

func set_script_temporary(script_file: ScriptFileCore):
	if script_file.turns_to_live == 0:
		return
	script_temporary_label.text = "[img]res://Art/Office Pack/Battle/Icons/MISC/temporary.png[/img] " + \
			 TranslationServer.translate("BATTLE_TURNS") + ": " + str(script_file.turns_to_live)
	script_temporary_label.visible = true

func set_script_auto_deleted(script_file: ScriptFileCore):
	if !script_file.auto_deleted:
		return
	script_auto_deleted_label.text = "Auto deleted after executing"
	script_auto_deleted_label.visible = true

func set_script_description(script_file: ScriptFileCore):
	var desc_line = TranslationServer.translate("BATTLE_TOOLTIP_" + script_file.script_name.to_upper())
	for i in script_file.values.size():
		desc_line = desc_line.replace("<val" + str(i) + ">",
				"[color=" + ColourPalette.green + "]" + str(script_file.values[i].value) + \
				TranslationServer.translate(script_file.values[i].suffix) + "[/color]")
	script_description_label.text = desc_line
	script_description_label.visible = true

func set_script_prices(script_file: ScriptFileCore):
	if script_file.copy_price != 0:
		script_copy_price_label.text = get_price_str(script_file, BattleCommonCore.price_types.COPY)
		script_copy_price_label.visible = true
	if script_file.delete_price != 0:
		script_delete_price_label.text = get_price_str(script_file, BattleCommonCore.price_types.DELETE)
		script_delete_price_label.visible = true
	if script_file.run_price != 0:
		script_run_price_label.text = get_price_str(script_file, BattleCommonCore.price_types.RUN)
		script_run_price_label.visible = true
	if script_file.stop_price != 0:
		script_stop_price_label.text = get_price_str(script_file, BattleCommonCore.price_types.STOP)
		script_stop_price_label.visible = true

func set_script_load(script_file: ScriptFileCore):
	if script_file.item_type != BattleCommonCore.item_types.RAM_SCRIPT:
		return
	var is_loading = false
	for i in range(script_file.cpus.size()):
		var spc: BattleCommonCore.script_per_cpu = script_file.cpus[i]
		var label: RichTextLabel = script_load_cpus_list.get_child(i)
		if !spc.selected or spc.max_load == 0:
			label.visible = false
		else:
			var load_str = "CPU " + str(spc.cpu_node.id + 1) + ": " + str(spc.cur_load) + "/" + str(spc.max_load)
			if spc.num_of_mod == 1:
				load_str += " (mod 1)"
			elif spc.num_of_mod > 1:
				load_str += " (mods 1-" + str(spc.num_of_mod) + ")"
			label.text = load_str
			label.visible = true
			is_loading = true
	if !is_loading:
		return
	script_load_header_label.text = "[color=" + header_colour + "]Load[/color]"
	script_load_list.visible = true

func set_script_modifiers(script_file: ScriptFileCore):
	if script_file.item_type != BattleCommonCore.item_types.RAM_SCRIPT:
		return
	var has_mods = false
	for i in range(script_file.cpus.size()):
		var spc: BattleCommonCore.script_per_cpu = script_file.cpus[i]
		var label: RichTextLabel = script_modifiers_cpus_list.get_child(i)
		if !spc.selected or spc.mod_id == -1:
			label.visible = false
		else:
			var load_str = "CPU " + str(spc.cpu_node.id + 1) + \
				": [color=" + ColourPalette.red + "]#" + str(spc.mod_id + 1) + "[/color]"
			label.text = load_str
			label.visible = true
			has_mods = true
	if !has_mods:
		return
	script_modifiers_header_label.text = "[color=" + header_colour + "]Modifiers[/color]"
	script_modifiers_list.visible = true

func set_script_traffic(script_file: ScriptFileCore):
	if script_file.item_type != BattleCommonCore.item_types.RAM_SCRIPT or script_file.traffic_total == 0:
		return
	var cur_traffic = 0
	for i in script_file.ifaces:
		var label: RichTextLabel
		label = script_traffic_ifaces_local_list.get_child(i.iface_node.id)
		if !i.selected:
			label.visible = false
		else:
			label.text = i.iface_node.iface_name + str(i.iface_node.id + 1) + ": " + str(i.cur_traffic) + "/" + str(i.max_traffic)
			label.visible = true
			cur_traffic += i.cur_traffic
	for i in script_file.opp_ifaces:
		var label: RichTextLabel
		label = script_traffic_ifaces_remote_list.get_child(i.iface_node.id)
		if !i.selected:
			label.visible = false
		else:
			label.text = i.iface_node.iface_name + str(i.iface_node.id + 1) + ": " + str(i.cur_traffic) + "/" + str(i.max_traffic)
			label.visible = true
	script_traffic_header_label.text = "[color=" + header_colour + "]Traffic[/color] left: " + \
			str(script_file.traffic_left) + "/" + str(script_file.traffic_total) + ", this turn: " + str(cur_traffic)
	script_traffic_list.visible = true

func prepare_script_load(script_file: ScriptFileCore):
	for i in range(script_file.cpus.size()):
		script_load_cpus_list.add_child(get_new_label("CPU" + str(i + 1)))

func prepare_script_modifiers(script_file: ScriptFileCore):
	for i in range(script_file.cpus.size()):
		script_modifiers_cpus_list.add_child(get_new_label("CPU" + str(i + 1)))

func prepare_script_traffic(script_file: ScriptFileCore):
	for i in script_file.ifaces:
		script_traffic_ifaces_local_list.add_child(get_new_label("Iface" + str(i.iface_node.id + 1)))
	for i in script_file.opp_ifaces:
		script_traffic_ifaces_remote_list.add_child(get_new_label("Iface" + str(i.iface_node.id + 1)))

# CPU

func set_cpu_name(cpu: CPUBarCore):
	var name_str = "[color=" + header_colour + "]CPU " + str(cpu.id + 1)
	if cpu.is_vm:
		name_str += "v"
	name_str += "[/color]"
	cpu_name_label.text = name_str
	cpu_name_label.visible = true

func set_cpu_load(cpu: CPUBarCore):
	if !cpu.status == BattleCommonCore.cpu_states.BROKEN:
		cpu_load_label.text = str(cpu.cur_load) + "/" + str(cpu.max_load) + " cycles"
	else:
		cpu_load_label.text = "Broken"
	cpu_load_label.visible = true

func set_cpu_modifiers(cpu: CPUBarCore):
	if cpu.modifiers.is_empty():
		cpu_modifiers_label.visible = false
		cpu_modifier_list.visible = false
		return
	for i in range(cpu.max_mod_num):
		var label: RichTextLabel
		label = cpu_modifier_list.get_child(i)
		if i >= cpu.modifiers.size():
			label.visible = false
		else:
			label.text = "[color=" + ColourPalette.red + "]#" + str(i + 1) + "[/color]: " + \
					get_modifier_string(cpu.modifiers[i]) + " (" + cpu.modifiers[i].source.script_name + ".sh)"
			label.visible = true
	cpu_modifiers_label.text = "[color=" + header_colour + "]Modifiers[/color]"
	cpu_modifiers_label.visible = true
	cpu_modifier_list.visible = true

func prepare_cpu_modifiers(cpu: CPUBarCore):
	for i in range(cpu.max_mod_num):
		cpu_modifier_list.add_child(get_new_label("Modifier" + str(i)))

# Iface

func set_iface_name(iface: NetInterfaceCore):
	iface_name_label.text = "[color=" + header_colour + "]" + iface.iface_name + str(iface.id + 1) + "[/color]"
	iface_name_label.visible = true

func set_iface_traffic(iface: NetInterfaceCore):
	iface_traffic_label.text = str(iface.cur_traffic) + "/" + str(iface.max_traffic) + " Gigabits"
	iface_traffic_label.visible = true

# Utility functions
func get_modifier_string(modifier: BattleCommonCore.load_mod):
	var res = ""
	match modifier.op:
		BattleCommonCore.operations.ADD_PERCENT:
			res += "+" + str(modifier.val) + "%"
		BattleCommonCore.operations.DEC_PERCENT:
			res += "-" + str(modifier.val) + "%"
		BattleCommonCore.operations.ADD_FLAT:
			res += "+" + str(modifier.val) + TranslationServer.translate("BATTLE_CPU_UNIT")
		BattleCommonCore.operations.DEC_FLAT:
			res += "-" + str(modifier.val) + TranslationServer.translate("BATTLE_CPU_UNIT")
		BattleCommonCore.operations.MAX:
			res += "max " + str(modifier.val) + TranslationServer.translate("BATTLE_CPU_UNIT")
		BattleCommonCore.operations.MIN:
			res += "min " + str(modifier.val) + TranslationServer.translate("BATTLE_CPU_UNIT")
	return res

func get_new_label(label_name: String):
	var label: RichTextLabel
	label = RichTextLabel.new()
	label.name = label_name
	label.bbcode_enabled = true
	label.fit_content = true
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label

func get_price_str(script_file: ScriptFileCore, price_type: BattleCommonCore.price_types):
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
	
	price_str = "[img]res://Art/Office Pack/Battle/Icons/Actions/" + action + ".png[/img] " + action + " price: "
	price_deviation = script_file.get_cur_price_deviation(price_type)
	if price_deviation > 0:
		price_str += "[color=" + ColourPalette.red + "]" + str(script_file.get_cur_price(price_type)) + "[/color]s"
	elif price_deviation < 0:
		price_str += "[color=" + ColourPalette.green + "]" + str(script_file.get_cur_price(price_type)) + "[/color]s"
	else:
		price_str += str(script_file.get_cur_price(price_type)) + "s"
	return price_str
