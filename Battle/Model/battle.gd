class_name Battle

var cur_selection = Selections.new()
var history: Array[ScriptFileCore] = []

# --- Public ---

func click_manager(item: ItemCore, mouse_button: BattleCommonCore.mouse_buttons, subject: SystemCore):
	if !subject.active:
		return BattleCommonCore.action_types.NONE
	
	if cur_selection.is_inactive():
		if item is not ScriptFileCore:
			return BattleCommonCore.action_types.NONE
		if !item.location_system.check_permission(subject, item.location, mouse_button):
			return BattleCommonCore.action_types.NONE
		var res = false
		match mouse_button:
			BattleCommonCore.mouse_buttons.LEFT:
				match item.item_type:
					BattleCommonCore.item_types.DISK_D_SCRIPT:
						res = left_click_disk_d_script(item, subject)
					BattleCommonCore.item_types.DISK_C_SCRIPT:
						res = left_click_disk_c_script(item, subject)
			BattleCommonCore.mouse_buttons.RIGHT:
				match item.item_type:
					BattleCommonCore.item_types.DISK_C_SCRIPT:
						res = right_click_disk_c_script(item, subject)
					BattleCommonCore.item_types.RAM_SCRIPT:
						res = right_click_ram_script(item, subject)
		return res
	elif cur_selection.is_item_active():
		if mouse_button != BattleCommonCore.mouse_buttons.LEFT:
			return BattleCommonCore.action_types.NONE
		if !item.highlighted:
			return BattleCommonCore.action_types.NONE
		cur_selection.item_choose(item)
		if cur_selection.is_item_ready():
			return activate_script(cur_selection.get_pending_script(), subject)
		else:
			return BattleCommonCore.action_types.SELECTION
	else:
		return BattleCommonCore.action_types.NONE

func click_system(object: SystemCore, subject: SystemCore):
	if !subject.active:
		return BattleCommonCore.action_types.NONE
	
	if cur_selection.is_system_active():
		var script_file = cur_selection.get_pending_script()
		object.add_disk_c_script(script_file.resource_name, subject)
		subject.dec_price(script_file, BattleCommonCore.price_types.COPY)
		cur_selection.done()
		return BattleCommonCore.action_types.SMALL
	else:
		return BattleCommonCore.action_types.NONE

func click_end_turn(subject: SystemCore):
	if !subject.active:
		return false
	
	idle()
	subject.set_inactive()
	subject = subject.opponent
	scripts_before_turn(subject, subject)
	scripts_before_turn(subject.opponent, subject)
	subject.set_active()
	return true

func check_for_end(object: SystemCore):
	var self_all_broken = false
	var opp_all_broken = false
	
	if object.get_cpus(BattleCommonCore.cpu_types.REAL).size() == 0:
		self_all_broken = true
	if object.opponent.get_cpus(BattleCommonCore.cpu_types.REAL).size() == 0:
		opp_all_broken = true
	 
	if self_all_broken and opp_all_broken:
		return BattleCommonCore.results.DRAW
	elif self_all_broken and !opp_all_broken:
		return BattleCommonCore.results.LOSS
	elif !self_all_broken and opp_all_broken:
		return BattleCommonCore.results.WIN
	else:
		return BattleCommonCore.results.NONE

func idle():
	cur_selection.done()

func check_if_idle():
	return cur_selection.is_inactive()

# --- Private ---

func left_click_disk_d_script(script_file: ScriptFileCore, subject: SystemCore):
	if !subject.check_price(script_file, BattleCommonCore.price_types.COPY):
		return BattleCommonCore.action_types.NONE
	
	cur_selection.system_start(script_file, subject)
	return BattleCommonCore.action_types.SELECTION

func left_click_disk_c_script(script_file: ScriptFileCore, subject: SystemCore):
	if !script_file.available:
		return BattleCommonCore.action_types.NONE
	if !subject.check_price(script_file, BattleCommonCore.price_types.RUN):
		return BattleCommonCore.action_types.NONE
	if !cur_selection.item_check(script_file, subject):
		return BattleCommonCore.action_types.NONE
	
	cur_selection.item_start(script_file, subject)
	if cur_selection.is_item_active():
		return BattleCommonCore.action_types.SELECTION
	else:
		return activate_script(script_file, subject)

func right_click_disk_c_script(script_file: ScriptFileCore, subject: SystemCore):
	if !subject.check_price(script_file, BattleCommonCore.price_types.DELETE):
		return BattleCommonCore.action_types.NONE
	
	script_file.location_system.del_disk_c_script(script_file)
	subject.dec_price(script_file, BattleCommonCore.price_types.DELETE)
	return BattleCommonCore.action_types.SMALL

func right_click_ram_script(script_file: ScriptFileCore, subject: SystemCore):
	if !subject.check_price(script_file, BattleCommonCore.price_types.STOP):
		return BattleCommonCore.action_types.NONE
	
	return deactivate_script(script_file, subject)

func activate_script(script_file: ScriptFileCore, subject: SystemCore):
	var new_script_file = script_file.location_system.add_ram_script(script_file, subject)
	if !Scripts.activate(new_script_file, subject, cur_selection.item_get_choices()):
		script_file.location_system.del_ram_script(new_script_file)
		cur_selection.done()
		return BattleCommonCore.action_types.NONE
	cur_selection.done()
	subject.dec_price(script_file, BattleCommonCore.price_types.RUN)
	add_script_to_history(new_script_file)
	if script_file.auto_deleted:
		script_file.location_system.del_disk_c_script(script_file)
	rebalance(script_file.location_system)
	deactivate_limbo_scripts(script_file.location_system)
	return BattleCommonCore.action_types.MAIN

func deactivate_script(script_file: ScriptFileCore, subject: SystemCore):
	subject.dec_price(script_file, BattleCommonCore.price_types.STOP)
	script_file.location_system.move_script_to_limbo(script_file)
	deactivate_limbo_scripts(script_file.location_system)
	return BattleCommonCore.action_types.MAIN

func deactivate_limbo_scripts(object: SystemCore):
	while !object.limbo_scripts.is_empty():
		var script_file = object.limbo_scripts[0]
		stop_execution(script_file, false)
		object.del_limbo_script(script_file)
		rebalance(script_file.location_system)

func stop_execution(script_file: ScriptFileCore, broken: bool):
	Scripts.deactivate(script_file)
	if !broken:
		Scripts.after_death_action(script_file)
	del_script_from_history(script_file)

func add_script_to_history(script: ScriptFileCore):
	history.append(script)

func del_script_from_history(script: ScriptFileCore):
	for i in range(history.size()):
		if history[i] == script:
			history.remove_at(i)
			break

func scripts_before_turn(object: SystemCore, subject: SystemCore):
	var ram_scripts = object.get_all_ram_scripts_for_owner(subject)
	for i in ram_scripts:
		Scripts.before_turn(i)
		rebalance(object)
	for i in range(ram_scripts.size() - 1, -1, -1):
		var script = ram_scripts[i]
		if script.turns_to_live != 0:
			script.turns_left -= 1
			if script.turns_left == 0:
				object.move_script_to_limbo(script)
		elif script.traffic_total != 0 and script.traffic_left == 0:
			object.move_script_to_limbo(script)
	rebalance(object)
	deactivate_limbo_scripts(object)

# Rebalancing

func delete_broken_scripts(object: SystemCore):
	var scripts_to_delete = []
	var scripts_deleted = 0
	for i in object.ram_scripts:
		if !i.cpu_bound:
			continue
		var cpu_num = 0
		for j in i.cpus:
			if j.selected:
				if j.cpu_node.status == BattleCommonCore.cpu_states.ACTIVE:
					cpu_num += 1
				elif j.cpu_node.status == BattleCommonCore.cpu_states.BROKEN:
					j.deselect()
		if cpu_num == 0:
			scripts_to_delete.append(i)
	scripts_deleted = scripts_to_delete.size()
	while scripts_to_delete.size() != 0:
		stop_execution(scripts_to_delete[0], true)
		object.del_ram_script(scripts_to_delete[0])
		scripts_to_delete.remove_at(0)
	return scripts_deleted

func rebalance(object: SystemCore):
	while true:
		reset_loads(object)
		fill_load(object)
		if delete_broken_scripts(object) == 0:
			break
	reset_traffic(object)
	reset_traffic(object.opponent)
	fill_traffic()
	object.calc_taucoin_inc()

func reset_loads(object: SystemCore):
	for i in object.ram_scripts:
		for j in i.cpus:
			j.cur_load = 0
	for i in object.cpus:
		i.reset_load()
		if i.has_vm:
			i.vm.reset_load()

func reset_traffic(object: SystemCore):
	for i in object.ram_scripts:
		for j in i.ifaces:
			j.cur_traffic = 0
	for i in object.ifaces:
		i.reset_traffic()

func fill_load(object: SystemCore):
	for script_file in object.ram_scripts:
		for i in script_file.cpus:
			if i.max_load == 0 or i.cpu_node.status != BattleCommonCore.cpu_states.ACTIVE:
				continue
			var res_load = i.cpu_node.get_resulting_load(i)
			if res_load == 0:
				continue
			i.cur_load = res_load
			i.cpu_node.add_load(res_load)

func fill_traffic():
	for script_file in history:
		if script_file.traffic_total == 0:
			continue
		var local_traffic_max = 0
		for i in script_file.ifaces:
			local_traffic_max += i.iface_node.get_resulting_traffic(i.max_traffic)
		var remote_traffic_max = 0
		for i in script_file.opp_ifaces:
			remote_traffic_max += i.iface_node.get_resulting_traffic(i.max_traffic)
		var cur_traffic = min(local_traffic_max, remote_traffic_max, script_file.traffic_left)
		var traffic_left = cur_traffic
		for i in script_file.ifaces:
			if i.max_traffic == 0:
				continue
			var res_traffic = i.iface_node.get_resulting_traffic(min(i.max_traffic, traffic_left))
			if res_traffic == 0:
				continue
			i.cur_traffic = res_traffic
			i.iface_node.add_traffic(res_traffic)
			traffic_left -= res_traffic
			if traffic_left == 0:
				break
		traffic_left = cur_traffic
		for i in script_file.opp_ifaces:
			if i.max_traffic == 0:
				continue
			var res_traffic = i.iface_node.get_resulting_traffic(min(i.max_traffic, traffic_left))
			if res_traffic == 0:
				continue
			i.cur_traffic = res_traffic
			i.iface_node.add_traffic(res_traffic)
			traffic_left -= res_traffic
			if traffic_left == 0:
				break
