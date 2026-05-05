class_name Scripts

static func activate(script_file: ScriptFileCore, subject: SystemCore, choices: Array[ItemCore]):
	match script_file.script_name:
		"basic_load", \
		"mini_load", \
		"self_load", \
		"gain", \
		"high_bounty", \
		"low_bounty":
			var cpu = choices[0] as CPUBarCore
			var load_added = int(script_file.values[0].value)
			
			script_file.set_max_load(cpu, load_added)
		"big_load":
			var cpu = choices[0] as CPUBarCore
			var base_load_added = int(script_file.values[0].value)
			var max_dataweave_needed = int(script_file.values[1].value)
			var step_load_added = int(script_file.values[2].value)
			var dataweave_needed = min(subject.cur_dataweave, max_dataweave_needed)
			
			subject.dec_token(BattleCommonCore.tokens.DATAWEAVE, dataweave_needed)
			script_file.set_max_load(cpu, base_load_added + step_load_added * dataweave_needed)
		"vm_aware":
			var cpu = choices[0] as CPUBarCore
			var cortex_needed = int(script_file.values[0].value)
			var base_load_added = int(script_file.values[1].value)
			var load_added: int
			if subject.check_token(BattleCommonCore.tokens.CORTEX, cortex_needed):
				return false
			if cpu.vm_active:
				load_added = cpu.vm_max_load - cpu.vm_load
			else:
				load_added = base_load_added
			
			subject.dec_token(BattleCommonCore.tokens.CORTEX, cortex_needed)
			script_file.set_max_load(cpu, load_added)
		"multi_load":
			var load_added = int(script_file.values[0].value)
			
			for i in script_file.location_system.cpus:
				script_file.set_max_load(i, load_added)
		"copy_jam":
			var price_mod = int(script_file.values[0].value)
			
			script_file.location_system.add_price_mod(BattleCommonCore.price_types.COPY, price_mod)
		"del_jam":
			var price_mod = int(script_file.values[0].value)
			
			script_file.location_system.add_price_mod(BattleCommonCore.price_types.DELETE, price_mod)
		"run_jam":
			var price_mod = int(script_file.values[0].value)
			
			script_file.location_system.add_price_mod(BattleCommonCore.price_types.RUN, price_mod)
		"stop_jam":
			var price_mod = int(script_file.values[0].value)
			
			script_file.location_system.add_price_mod(BattleCommonCore.price_types.STOP, price_mod)
		"copy_boost":
			var price_mod = int(script_file.values[0].value)
			
			script_file.location_system.add_price_mod(BattleCommonCore.price_types.COPY, -price_mod)
		"del_boost":
			var price_mod = int(script_file.values[0].value)
			
			script_file.location_system.add_price_mod(BattleCommonCore.price_types.DELETE, -price_mod)
		"run_boost":
			var price_mod = int(script_file.values[0].value)
			
			script_file.location_system.add_price_mod(BattleCommonCore.price_types.RUN, -price_mod)
		"stop_boost":
			var price_mod = int(script_file.values[0].value)
			
			script_file.location_system.add_price_mod(BattleCommonCore.price_types.STOP, -price_mod)
		"basic_vm", \
		"big_vm":
			var cpu = choices[0] as CPUBarCore
			var load_added = int(script_file.values[0].value)
			var vm_max_load = int(script_file.values[1].value)
			if cpu.has_vm or cpu.is_vm:
				return false
			
			script_file.set_max_load(cpu, load_added)
			script_file.location_system.add_vm(cpu.id, vm_max_load)
		"rootkit":
			var min_load_needed = int(script_file.values[0].value)
			var cpu_found = false
			for i in script_file.location_system.cpus:
				if i.status == BattleCommonCore.cpu_states.ACTIVE and i.cur_load >= min_load_needed:
					cpu_found = true
			if !cpu_found:
				return false
			if !script_file.location_system.check_if_sudo_locked():
				return false
			
			script_file.location_system.unlock_sudo()
		"backdoor":
			var min_traffic_needed = int(script_file.values[0].value)
			var iface_found = false
			for i in script_file.location_system.opponent.ifaces:
				if i.cur_traffic == min_traffic_needed:
					iface_found = true
			if !iface_found:
				return false
			if !script_file.location_system.check_if_sudo_locked():
				return false
			
			script_file.location_system.unlock_sudo()
		"pagesys":
			if script_file.location_system.cur_disk_c_scripts < script_file.location_system.max_disk_c_scripts:
				return false
			if !script_file.location_system.check_if_sudo_locked():
				return false
			
			script_file.location_system.unlock_sudo()
		"overload":
			var min_load_needed = int(script_file.values[0].value)
			var cpu_found = false
			for i in script_file.location_system.cpus:
				if i.status == BattleCommonCore.cpu_states.ACTIVE and i.cur_load >= min_load_needed:
					cpu_found = true
			if !cpu_found:
				return false
			if !script_file.location_system.check_if_taucoin_stolen():
				return false
			
			script_file.location_system.steal_taucoin()
		"overwhelm":
			var min_traffic_needed = int(script_file.values[0].value)
			var iface_found = false
			for i in script_file.location_system.opponent.ifaces:
				if i.cur_traffic == min_traffic_needed:
					iface_found = true
			if !iface_found:
				return false
			if !script_file.location_system.check_if_taucoin_stolen():
				return false
			
			script_file.location_system.steal_taucoin()
		"overfill":
			if script_file.location_systemect.cur_disk_c_scripts < script_file.location_system.max_disk_c_scripts:
				return false
			if !script_file.location_system.check_if_taucoin_stolen():
				return false
			
			script_file.location_system.steal_taucoin()
		"basic_traffic", \
		"worm":
			var iface1 = choices[0] as NetInterfaceCore
			var iface2 = choices[1] as NetInterfaceCore
			var traffic_total = int(script_file.values[0].value)
			var traffic_added = int(script_file.values[1].value)
			
			script_file.set_total_traffic(traffic_total)
			script_file.set_max_traffic(iface1.id, traffic_added)
			script_file.set_opp_max_traffic(iface2.id, traffic_added)
		"ddos":
			var iface = choices[0] as NetInterfaceCore
			var traffic_total = int(script_file.values[0].value)
			var traffic_added = int(script_file.values[1].value)
			
			script_file.set_total_traffic(traffic_total)
			for i in script_file.location_system.ifaces:
				script_file.set_max_traffic(i.id, traffic_added)
			script_file.set_opp_max_traffic(iface.id, traffic_added * script_file.location_system.ifaces.size())
		"upload":
			var selected_script = choices[0] as ScriptFileCore
			var iface1 = choices[1] as NetInterfaceCore
			var iface2 = choices[2] as NetInterfaceCore
			var traffic_total_mult = int(script_file.values[0].value)
			var traffic_added = int(script_file.values[1].value)
			
			script_file.set_total_traffic(selected_script.copy_price * traffic_total_mult)
			script_file.set_max_traffic(iface1.id, traffic_added)
			script_file.set_opp_max_traffic(iface2.id, traffic_added)
			script_file.set_payload(selected_script)
		"kill":
			var cpu = choices[0] as CPUBarCore
			var petrichor_needed = int(script_file.values[0].value)
			var cortex_generated = int(script_file.values[1].value)
			var max_load = 0
			var selected_script = null
			for i in script_file.location_system.ram_scripts:
				if i == script_file:
					continue
				if cpu.vm_active and !i.cpus[cpu.id].vm:
					continue
				if i.cpus[cpu.id].cur_load > max_load:
					selected_script = i
			if !selected_script:
				return false
			if subject.check_token(BattleCommonCore.tokens.PETRICHOR, petrichor_needed):
				return false
			
			script_file.select_cpu(cpu)
			subject.dec_token(BattleCommonCore.tokens.PETRICHOR, petrichor_needed)
			script_file.location_system.move_script_to_limbo(selected_script)
			subject.add_token(BattleCommonCore.tokens.CORTEX, cortex_generated)
		"kill_pro":
			var cpu = choices[0] as CPUBarCore
			var petrichor_needed = int(script_file.values[0].value)
			var cortex_generated = int(script_file.values[1].value)
			var scripts_to_delete = []
			for i in script_file.location_system.ram_scripts:
				if i == script_file or i.to_delete:
					continue
				if cpu.vm_active and !i.cpu_vm[cpu.id]:
					continue
				scripts_to_delete.append(i)
			if scripts_to_delete.size() == 0:
				return false
			if subject.cur_petrichor < petrichor_needed:
				return false
			
			script_file.select_cpu(cpu)
			subject.dec_token(BattleCommonCore.tokens.PETRICHOR, petrichor_needed)
			for i in scripts_to_delete:
				script_file.location_system.move_script_to_limbo(i)
			subject.add_token(BattleCommonCore.tokens.CORTEX, cortex_generated)
		"merge":
			var cortex_needed = int(script_file.values[0].value)
			var dataweave_needed = int(script_file.values[1].value)
			var petrichor_needed = int(script_file.values[2].value)
			if subject.cur_cortex < cortex_needed:
				return false
			if subject.cur_dataweave < dataweave_needed:
				return false
			if subject.cur_petrichor < petrichor_needed:
				return false
			
			subject.dec_token(BattleCommonCore.tokens.CORTEX, cortex_needed)
			subject.dec_token(BattleCommonCore.tokens.DATAWEAVE, dataweave_needed)
			subject.dec_token(BattleCommonCore.tokens.PETRICHOR, petrichor_needed)
		"app_guard":
			var cpu = choices[0] as CPUBarCore
			var modifier_val = int(script_file.values[0].value.substr(1))
			if cpu.check_if_modifiers_full():
				return false
			
			script_file.select_cpu(cpu)
			cpu.add_modifier(script_file, BattleCommonCore.operations.DEC_PERCENT, modifier_val)
		"app_policy":
			var cpu = choices[0] as CPUBarCore
			var modifier_val = int(script_file.values[0].value.substr(1))
			if cpu.check_if_modifiers_full():
				return false
			
			script_file.select_cpu(cpu)
			cpu.add_modifier(script_file, BattleCommonCore.operations.DEC_FLAT, modifier_val)
	return true

static func deactivate(script_file: ScriptFileCore):
	match script_file.script_name:
		"copy_jam":
			var price_mod = int(script_file.values[0].value)
			
			script_file.location_system.add_price_mod(BattleCommonCore.price_types.COPY, -price_mod)
		"del_jam":
			var price_mod = int(script_file.values[0].value)
			
			script_file.location_system.add_price_mod(BattleCommonCore.price_types.DELETE, -price_mod)
		"run_jam":
			var price_mod = int(script_file.values[0].value)
			
			script_file.location_system.add_price_mod(BattleCommonCore.price_types.RUN, -price_mod)
		"stop_jam":
			var price_mod = int(script_file.values[0].value)
			
			script_file.location_system.add_price_mod(BattleCommonCore.price_types.STOP, -price_mod)
		"copy_boost":
			var price_mod = int(script_file.values[0].value)
			
			script_file.location_system.add_price_mod(BattleCommonCore.price_types.COPY, price_mod)
		"del_boost":
			var price_mod = int(script_file.values[0].value)
			
			script_file.location_system.add_price_mod(BattleCommonCore.price_types.DELETE, price_mod)
		"run_boost":
			var price_mod = int(script_file.values[0].value)
			
			script_file.location_system.add_price_mod(BattleCommonCore.price_types.RUN, price_mod)
		"stop_boost":
			var price_mod = int(script_file.values[0].value)
			
			script_file.location_system.add_price_mod(BattleCommonCore.price_types.STOP, price_mod)
		"basic_vm", \
		"big_vm":
			for i in script_file.get_selected_cpus():
				if i.check_if_vm_running():
					i.del_vm()
		"app_guard", \
		"app_policy":
			for i in script_file.get_selected_cpus():
				i.del_modifier(script_file)

static func after_death_action(script_file: ScriptFileCore):
	match script_file.script_name:
		"hash":
			var cortex_generated = int(script_file.values[0].value)
			
			script_file.location_system.add_token(BattleCommonCore.tokens.CORTEX, cortex_generated)
		"merge":
			var fractal_generated = int(script_file.values[3].value)
			
			script_file.location_system.add_token(BattleCommonCore.tokens.FRACTAL, fractal_generated)
		"sanitizer":
			var scripts_to_delete = []
			for i in script_file.location_system.ram_scripts:
				if i == script_file:
					continue
				scripts_to_delete.append(i)
			
			for i in scripts_to_delete:
				script_file.location_system.move_script_to_limbo(i)
		"upload":
			if script_file.traffic_left == 0:
				script_file.location_system.add_disk_c_script(script_file.payload.script_name, script_file.owner_system)

static func before_turn(script_file: ScriptFileCore):
	match script_file.script_name:
		"self_load":
			var dataweave_generated = int(script_file.values[1].value)
			
			script_file.location_system.add_token(BattleCommonCore.tokens.DATAWEAVE, dataweave_generated)
		"gain":
			if script_file.stop_price > int(script_file.values[4].value):
				script_file.stop_price -= int(script_file.values[3].value)
			for i in script_file.cpu_load.size():
				if script_file.cpus[i].selected:
					if script_file.cpus[i].max_load < int(script_file.values[2].value):
						script_file.cpus[i].max_load += int(script_file.values[1].value)
		"basic_traffic", \
		"ddos", \
		"upload":
			for i in script_file.ifaces:
				if i.cur_traffic != 0:
					script_file.traffic_left -= i.cur_traffic
		"worm":
			var traffic_sent = script_file.traffic_total - script_file.traffic_left
			for i in script_file.ifaces:
				if i.cur_traffic != 0:
					script_file.traffic_left -= i.cur_traffic
					var tokens_generated = traffic_sent / i.max_traffic
					var tokens_target = (traffic_sent + i.cur_traffic) / i.max_traffic
					if tokens_target > tokens_generated:
						script_file.location_system.add_token(BattleCommonCore.tokens.PETRICHOR, tokens_target - tokens_generated)
