class_name System extends PanelContainer

signal item_added(item: Control)

const template_cpu_node = preload("res://Battle/View/cpu_bar.tscn")
const template_script_node = preload("res://Battle/View/script_file.tscn")
const template_iface_node = preload("res://Battle/View/net_interface.tscn")
const template_tooltip = preload("res://Battle/View/tooltip.tscn")

@onready var cpu_space: VBoxContainer = $MarginContainer/HBoxContainer/CPU/Bars/VBoxContainer
@onready var iface_space: VBoxContainer = $MarginContainer/HBoxContainer/MISC/Network/Interfaces/VBoxContainer
@onready var disk_d: VBoxContainer = $MarginContainer/HBoxContainer/DiskD/Files/VBoxContainer
@onready var disk_c: VBoxContainer = $MarginContainer/HBoxContainer/DiskC/Files/VBoxContainer
@onready var ram: VBoxContainer = $MarginContainer/HBoxContainer/RAM/Processes/VBoxContainer
@onready var disk_d_actions: RichTextLabel = $MarginContainer/HBoxContainer/DiskD/HBoxContainer/Actions
@onready var disk_c_actions: RichTextLabel = $MarginContainer/HBoxContainer/DiskC/HBoxContainer/Actions
@onready var ram_actions: RichTextLabel = $MarginContainer/HBoxContainer/RAM/HBoxContainer/Actions
@onready var disk_c_memory: RichTextLabel = $MarginContainer/HBoxContainer/DiskC/HBoxContainer/Memory
@onready var sudo_label: RichTextLabel = $MarginContainer/HBoxContainer/CPU/HBoxContainer/Sudo
@onready var cortex_label: RichTextLabel = $MarginContainer/HBoxContainer/MISC/DiskE/Tokens/VBoxContainer/Cortex
@onready var dataweave_label: RichTextLabel = $MarginContainer/HBoxContainer/MISC/DiskE/Tokens/VBoxContainer2/Dataweave
@onready var petrichor_label: RichTextLabel = $MarginContainer/HBoxContainer/MISC/DiskE/Tokens/VBoxContainer3/Petrichor
@onready var loom_label: RichTextLabel = $MarginContainer/HBoxContainer/MISC/DiskE/Tokens/VBoxContainer/Loom
@onready var fractal_label: RichTextLabel = $MarginContainer/HBoxContainer/MISC/DiskE/Tokens/VBoxContainer2/Fractal
@onready var taucoin_label: RichTextLabel = $MarginContainer/HBoxContainer/MISC/DiskE/Tokens/VBoxContainer3/Taucoin
@onready var taucoin_inc_label: RichTextLabel = $MarginContainer/HBoxContainer/CPU/HBoxContainer/TaucoinsInc
@onready var seconds: RichTextLabel = $MarginContainer/HBoxContainer/CPU/HBoxContainer/Seconds
@onready var border: NinePatchRect = $Border
@onready var wallpaper: Wallpaper = $MarginContainer/Wallpaper
var bounty_label: RichTextLabel

var system_name: String

var interactible: bool = false
var upper: bool

var model: SystemCore

# --- Public ---

func prepare(player_data: PlayerSpecs, p_bounty_label: RichTextLabel, p_upper: bool):
	bounty_label = p_bounty_label
	system_name = player_data.player_name
	upper = p_upper
	wallpaper.set_wallpaper(player_data.wallpaper.internal_name)

func update_full():
	update_cpus()
	
	for i in model.cpus:
		if !i.view:
			create_view(i, template_cpu_node, cpu_space, BattleCommon.tooltip_types.CPU)
			create_view(i.vm, template_cpu_node, cpu_space, BattleCommon.tooltip_types.CPU)
		i.view.update()
		i.vm.view.update()
	
	for i in model.ifaces:
		if !i.view:
			create_view(i, template_iface_node, iface_space, BattleCommon.tooltip_types.IFACE)
		i.view.update()
	
	for i in disk_d.get_children():
		if i.model.dead:
			i.model = null
			disk_d.remove_child(i)
			i.queue_free()
	for i in model.disk_d_scripts:
		if !i.view:
			create_view(i, template_script_node, disk_d, BattleCommon.tooltip_types.SCRIPT)
		i.view.update()
	
	for i in disk_c.get_children():
		if i.model.dead:
			i.model = null
			disk_c.remove_child(i)
			i.queue_free()
	for i in model.disk_c_scripts:
		if !i.view:
			create_view(i, template_script_node, disk_c, BattleCommon.tooltip_types.SCRIPT)
		i.view.update()
	
	for i in ram.get_children():
		if i.model.dead:
			i.model = null
			ram.remove_child(i)
			i.queue_free()
	for i in model.ram_scripts:
		if !i.view:
			create_view(i, template_script_node, ram, BattleCommon.tooltip_types.SCRIPT)
		i.view.update()
	
	update_sudo()
	update_seconds()
	update_taucoin_inc()
	update_disk_c_memory()
	update_tokens()
	update_bounty()
	update_actions()
	update_border()
	update_highlights()

func update_disk_c():
	for i in disk_c.get_children():
		if !i.model:
			disk_c.remove_child(i)
			i.queue_free()
	for i in model.disk_c_scripts:
		if !i.view:
			create_view(i, template_script_node, disk_c, BattleCommon.tooltip_types.SCRIPT)
		i.view.update()
	
	update_disk_c_memory()
	update_tokens()

func update_highlights():
	for i in model.cpus:
		if i.highlighted:
			i.view.highlight()
		else:
			i.view.idle()
	for i in model.vcpus:
		if i.highlighted:
			i.view.highlight()
		else:
			i.view.idle()
	for i in model.ifaces:
		if i.highlighted:
			i.view.highlight()
		else:
			i.view.idle()
	for i in model.disk_d_scripts:
		if i.highlighted:
			i.view.highlight()
		else:
			i.view.idle()

func set_interactible():
	interactible = true

func is_interactible():
	return interactible

func pause():
	wallpaper.pause()

func resume():
	wallpaper.resume()

# --- Private ---

func create_view(item: ItemCore, template: PackedScene, space: VBoxContainer, tooltip_type: BattleCommon.tooltip_types):
	var new_view = template.instantiate()
	new_view.model = item
	item.view = new_view
	space.add_child(new_view)
	add_tooltip(new_view, tooltip_type)
	item_added.emit(new_view)

func update_bounty():
	var bounty_line = system_name + TranslationServer.translate("BATTLE_BOUNTY_NAME")
	if model.bounty_cur_turn == -1:
		bounty_line += TranslationServer.translate("BATTLE_BOUNTY_NONE")
	elif model.bounty_cur_turn == 0:
		bounty_line += TranslationServer.translate("BATTLE_BOUNTY_NEXT")
	else:
		bounty_line += TranslationServer.translate("BATTLE_BOUNTY_CUR")
		bounty_line = bounty_line.replace("<val0>", str(model.bounty_cur_turn))
		bounty_line = bounty_line.replace("<val1>", str(model.bounty_active_turns))
	bounty_label.text = bounty_line

func update_sudo():
	var sudo_str: String
	match model.sudo:
		BattleCommonCore.sudo_statuses.LOCKED:
			sudo_str = "locked"
		BattleCommonCore.sudo_statuses.UNLOCKED:
			sudo_str = "unlocked"
		BattleCommonCore.sudo_statuses.OPEN:
			sudo_str = "open"
	sudo_label.text = "[img]res://Art/Office Pack/Battle/Icons/MISC/" + sudo_str + ".png[/img]"

func update_actions():
	var cur_am: BattleCommonCore.access_matrix = get_current_interactor_rights()
	disk_d_actions.text = \
			get_action_line(cur_am, BattleCommonCore.locations.DISK_D, BattleCommonCore.mouse_buttons.LEFT) + \
			get_action_line(cur_am, BattleCommonCore.locations.DISK_D, BattleCommonCore.mouse_buttons.RIGHT)
	disk_c_actions.text = \
			get_action_line(cur_am, BattleCommonCore.locations.DISK_C, BattleCommonCore.mouse_buttons.LEFT) + \
			get_action_line(cur_am, BattleCommonCore.locations.DISK_C, BattleCommonCore.mouse_buttons.RIGHT)
	ram_actions.text = \
			get_action_line(cur_am, BattleCommonCore.locations.RAM, BattleCommonCore.mouse_buttons.LEFT) + \
			get_action_line(cur_am, BattleCommonCore.locations.RAM, BattleCommonCore.mouse_buttons.RIGHT)

func update_disk_c_memory():
	disk_c_memory.text = str(model.disk_c_scripts.size()) + "/" + str(model.max_disk_c_scripts)

func update_taucoin_inc():
	var taucoin_inc_line: String = ""
	taucoin_inc_line += "[img]res://Art/Office Pack/Battle/Icons/Tokens/"
	if model.taucoin_stolen:
		taucoin_inc_line += "stolen_"
	taucoin_inc_line += "taucoin.png[/img] +" + str(model.cur_taucoin_inc)
	taucoin_inc_label.text = taucoin_inc_line

func update_seconds():
	seconds.text = str(model.cur_seconds) + "/" + str(model.max_seconds)

func update_tokens():
	cortex_label.text = "[img]res://Art/Office Pack/Battle/Icons/Tokens/cortex.png[/img] " + \
			str(model.get_token(BattleCommonCore.tokens.CORTEX))
	petrichor_label.text = "[img]res://Art/Office Pack/Battle/Icons/Tokens/petrichor.png[/img] " + \
			str(model.get_token(BattleCommonCore.tokens.PETRICHOR))
	dataweave_label.text = "[img]res://Art/Office Pack/Battle/Icons/Tokens/dataweave.png[/img] " + \
			str(model.get_token(BattleCommonCore.tokens.DATAWEAVE))
	loom_label.text = "[img]res://Art/Office Pack/Battle/Icons/Tokens/loom.png[/img] " + \
			str(model.get_token(BattleCommonCore.tokens.LOOM))
	fractal_label.text = "[img]res://Art/Office Pack/Battle/Icons/Tokens/fractal.png[/img] " + \
			str(model.get_token(BattleCommonCore.tokens.FRACTAL))
	taucoin_label.text = "[img]res://Art/Office Pack/Battle/Icons/Tokens/taucoin.png[/img] " + \
			str(model.get_token(BattleCommonCore.tokens.TAUCOIN))

func update_border():
	if model.active:
		border.visible = true
	else:
		border.visible = false

func update_cpus():
	var cur_type = get_current_interactor_rights().type
	for i in model.cpus:
		if i.has_vm:
			if i.vm.status == BattleCommonCore.cpu_states.BROKEN:
				i.view.set_available()
				i.vm.view.set_unavailable()
			elif cur_type == BattleCommonCore.user_types.ROOT:
				i.view.set_available()
				i.vm.view.set_available()
			else:
				i.view.set_unavailable()
				i.vm.view.set_available()
		else:
			i.set_active()

func get_current_interactor_rights():
	if model.sudo == BattleCommonCore.sudo_statuses.OPEN or (interactible and (model.active or !model.opponent.view.interactible)):
		return model.root_am
	else:
		return model.guest_am

func get_action_line(am: BattleCommonCore.access_matrix, loc: BattleCommonCore.locations, mb: BattleCommonCore.mouse_buttons):
	return "[img]res://Art/Office Pack/Battle/Icons/Actions/" + am.get_action_name(loc, mb) + ".png[/img]"

func add_tooltip(parent_node: Control, type: BattleCommon.tooltip_types):
	var new_tooltip = template_tooltip.instantiate()
	new_tooltip.upper = !upper
	new_tooltip.type = type
	new_tooltip.parent_node = parent_node
	parent_node.tooltip = new_tooltip
	parent_node.add_child(new_tooltip)
