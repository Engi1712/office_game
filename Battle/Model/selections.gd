class_name Selections

var status = BattleCommonCore.selection_state.NONE
var item_selections: Array[BattleCommonCore.item_group]
var item_ready: bool = false
var item_choices: Array[ItemCore]
var system_local: SystemCore = null
var system_remote: SystemCore = null
var pending_script: ScriptFileCore = null
var pending_subject: SystemCore = null

# Public

func item_start(script_file: ScriptFileCore, subject: SystemCore):
	if script_file.selections.is_empty():
		return
	for i in script_file.selections:
		var object: SystemCore
		if i.remote:
			object = script_file.location_system.opponent
		else:
			object = script_file.location_system
		item_selections.append(BattleCommonCore.item_group.new(object, i.type))
	pending_script = script_file
	pending_subject = subject
	status = BattleCommonCore.selection_state.ITEM
	item_highlight_selection()

func item_check(script_file: ScriptFileCore, subject: SystemCore):
	if script_file.selections.is_empty():
		return true
	for i in script_file.selections:
		var object: SystemCore
		if i.remote:
			object = script_file.location_system.opponent
		else:
			object = script_file.location_system
		item_selections.append(BattleCommonCore.item_group.new(object, i.type))
	pending_script = script_file
	pending_subject = subject
	
	var res = true
	res = res and check_item_group_avail(script_file.location_system, BattleCommonCore.item_types.CPU)
	res = res and check_item_group_avail(script_file.location_system, BattleCommonCore.item_types.IFACE)
	res = res and check_item_group_avail(script_file.location_system, BattleCommonCore.item_types.DISK_D_SCRIPT)
	res = res and check_item_group_avail(script_file.location_system.opponent, BattleCommonCore.item_types.CPU)
	res = res and check_item_group_avail(script_file.location_system.opponent, BattleCommonCore.item_types.IFACE)
	res = res and check_item_group_avail(script_file.location_system.opponent, BattleCommonCore.item_types.DISK_D_SCRIPT)
	item_selections.clear()
	pending_script = null
	pending_subject = null
	return res

func item_choose(item: ItemCore):
	item_choices.append(item)
	item_idle_selection()
	item_selections.remove_at(0)
	if item_selections.is_empty():
		item_ready = true
	else:
		item_highlight_selection()

func item_get_choices():
	return item_choices

func system_start(script_file: ScriptFileCore, subject: SystemCore):
	system_local = script_file.location_system
	system_remote = script_file.location_system.opponent
	pending_script = script_file
	pending_subject = subject
	status = BattleCommonCore.selection_state.SYSTEM
	system_highlight_selection()

func get_pending_script():
	return pending_script

func is_inactive():
	return status == BattleCommonCore.selection_state.NONE

func is_item_active():
	return status == BattleCommonCore.selection_state.ITEM

func is_system_active():
	return status == BattleCommonCore.selection_state.SYSTEM

func is_item_ready():
	return item_ready

func done():
	if status == BattleCommonCore.selection_state.ITEM:
		item_ready = false
		if !item_selections.is_empty():
			item_idle_selection()
		item_selections.clear()
		item_choices.clear()
	elif status == BattleCommonCore.selection_state.SYSTEM:
		system_idle_selection()
		system_local = null
		system_remote = null
	pending_script = null
	pending_subject = null
	status = BattleCommonCore.selection_state.NONE

# Private

func check_item_group_avail(object: SystemCore, type: BattleCommonCore.item_types):
	var cur_item_group = BattleCommonCore.item_group.new(object, type)
	var avail_items = count_selection(cur_item_group)
	var needed_items = count_item_group_occurance(cur_item_group)
	if avail_items < needed_items:
		return false
	else:
		return true

func count_item_group_occurance(items: BattleCommonCore.item_group):
	var cnt = 0
	for i in item_selections:
		if i.object == items.object and i.type == items.type:
			cnt += 1
	return cnt

func item_idle_selection():
	match item_selections[0].type:
		BattleCommonCore.item_types.CPU:
			item_selections[0].object.idle_cpus()
		BattleCommonCore.item_types.IFACE:
			item_selections[0].object.idle_ifaces()
		BattleCommonCore.item_types.DISK_D_SCRIPT:
			item_selections[0].object.idle_disk_d_scripts()

func item_highlight_selection():
	match item_selections[0].type:
		BattleCommonCore.item_types.CPU:
			if pending_script.type == BattleCommonCore.script_types.VM:
				item_selections[0].object.highlight_cpus(BattleCommonCore.cpu_types.AVAIL_REAL, item_choices)
			elif item_selections[0].object == pending_subject or !item_selections[0].object.check_if_sudo_locked():
				item_selections[0].object.highlight_cpus(BattleCommonCore.cpu_types.ALL, item_choices)
			else:
				item_selections[0].object.highlight_cpus(BattleCommonCore.cpu_types.CUR, item_choices)
		BattleCommonCore.item_types.IFACE:
			item_selections[0].object.highlight_ifaces(item_choices)
		BattleCommonCore.item_types.DISK_D_SCRIPT:
			item_selections[0].object.highlight_disk_d_scripts(item_choices)

func system_highlight_selection():
	system_local.highlight_disk_c()
	system_remote.highlight_disk_c()

func system_idle_selection():
	system_local.idle_disk_c()
	system_remote.idle_disk_c()

func count_selection(items: BattleCommonCore.item_group):
	match items.type:
		BattleCommonCore.item_types.CPU:
			if pending_script.type == BattleCommonCore.script_types.VM:
				return items.object.get_cpus(BattleCommonCore.cpu_types.AVAIL_REAL).size()
			elif items.object == pending_subject or !items.object.check_if_sudo_locked():
				return items.object.get_cpus(BattleCommonCore.cpu_types.ALL).size()
			else:
				return items.object.get_cpus(BattleCommonCore.cpu_types.CUR).size()
		BattleCommonCore.item_types.IFACE:
			return items.object.get_ifaces().size()
		BattleCommonCore.item_types.DISK_D_SCRIPT:
			return items.object.get_disk_d_scripts().size()
