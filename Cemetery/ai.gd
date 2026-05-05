#class_name AI
#
#enum action {NONE,
		#GET_DANGEROUS_SCRIPTS,
		#DEL_DANGEROUS_SCRIPTS,
		#NO_DANGEROUS_SCRIPTS,
		#FIND_CPU_TO_BREAK,
		#ATEMPT_DISK_C_BREAK,
		#COPY_DISK_D_BREAKING,
		#ATEMPT_CPU_BREAK,
		#CLICK_SCRIPT,
		#GET_ACTIVE_SCRIPTS}
#
#var dangerous_scripts: Array[ScriptLabel]
#var cpu_to_break: CPUBar
#var disk_c_breaking_scripts: Array[ScriptLabel]
#var disk_d_breaking_scripts: Array[ScriptLabel]
#var selected_script_id: int
#var waiting_for_cpu_select: bool
#var can_click_disk_d_scripts: bool
#var can_click_active_script: bool
#var subject_ram_attack_scripts: Array[ScriptLabel]
#var subject_disk_c_attack_scripts: Array[ScriptLabel]
#var subject_disk_c_defend_scripts: Array[ScriptLabel]
#var opponent_disk_c_attack_scripts: Array[ScriptLabel]
#var total_active_scripts: int
#var subject_cpu: CPUBar
#var opponent_cpu: CPUBar
#var last_action: action
#
#var battle: Battle
#
##func delete_scripts_bound_to_cpu(cpu_id: int, type: BattleCommon.cpu_types):
	##for i in range(ram_scripts.size() - 1, -1, -1):
		##var script_node = ram_scripts[i]
		##if !script_node.cpus[cpu_id].selected:
			##continue
		##if type == BattleCommon.cpu_types.VM and !script_node.cpus[cpu_id].is_vm:
			##continue
		##script_node.cpus[cpu_id].selected = false
		##script_node.cpus[cpu_id].max_load = 0
		##var still_working = false
		##for j in script_node.cpus:
			##if j.selected:
				##still_working = true
				##break
		##if !still_working:
			##del_ram_script(script_node)
#
##static func get_all_self_scripts(object: System):
	##var scripts: Array[ScriptLabelCore]
	##for i in object.disk_d_scripts:
		##scripts.append(i)
	##for i in object.disk_c_scripts:
		##if i.owner_system == object:
			##scripts.append(i)
	##for i in object.ram_scripts:
		##if i.owner_system == object:
			##scripts.append(i)
	##for i in object.opponent.disk_c_scripts:
		##if i.owner_system == object:
			##scripts.append(i)
	##for i in object.opponent.ram_scripts:
		##if i.owner_system == object:
			##scripts.append(i)
	##return scripts
#
##var enemy: AI
##var enemy_wait_time = 1
##var enemy_time_waited: float
##var enemy_turn_started: bool
##var enemy_turn_going: bool
##var enemy_last_action_res: bool
#
##func _ready():
	##if current_mode == BattleCommon.modes.BOT:
		##enemy = AI.new(battle)
		##enemy_turn_started = false
		##enemy_turn_going = false
		##enemy_last_action_res = false
#
##func _process(delta):
	##if current_mode != BattleCommon.modes.BOT:
		##return
	##if !enemy_turn_started:
		##return
	##if !enemy_turn_going:
		##end_turn_button.disabled = true
		##enemy.reset_state()
		##enemy_time_waited = 0.0
		##enemy_turn_going = true
		##enemy_last_action_res = false
	##else:
		##enemy_time_waited += delta
	##if enemy_time_waited >= enemy_wait_time:
		##if enemy_last_action_res:
			##battle.end_turn_click(battle.enemy)
			##enemy_turn_started = false
			##enemy_turn_going = false
			##end_turn_button.disabled = false
		##else:
			##enemy_last_action_res = enemy.make_action(battle.enemy)
			##enemy_time_waited = 0.0
#
#func _init(_battle: Battle):
	#battle = _battle
#
#func get_last_script(segment: VBoxContainer):
	#return segment.get_children()[segment.get_child_count() - 1]
#
#func find_max_loaded_cpus(object: System):
	#var cpus: Array[CPUBar]
	#var max_load = 0
	#for i in object.active_cpus:
		#if i.broken:
			#continue
		#if i.load > max_load:
			#cpus.clear()
			#cpus.append(i)
			#max_load = i.load
		#elif i.load == max_load:
			#cpus.append(i)
	#return cpus
#
#func find_max_loaded_cpus_no_vm(object: System):
	#var cpus: Array[CPUBar]
	#var max_load = 0
	#for i in object.active_cpus:
		#if i.broken:
			#continue
		#if i.load > max_load and !i.vm_active:
			#cpus.clear()
			#cpus.append(i)
			#max_load = i.load
		#elif i.load == max_load and !i.vm_active:
			#cpus.append(i)
	#return cpus
#
#func find_min_loaded_cpus_no_vm(object: System):
	#var cpus: Array[CPUBar]
	#var min_load = 100
	#for i in object.active_cpus:
		#if i.broken:
			#continue
		#if i.load < min_load and !i.vm_active:
			#cpus.clear()
			#cpus.append(i)
			#min_load = i.load
		#elif i.load == min_load and !i.vm_active:
			#cpus.append(i)
	#return cpus
#
#func find_scripts_max_loading_cpu(object: System, cpu: int):
	#var scripts: Array[ScriptLabel]
	#if object.cpus[cpu].load == 0:
		#return scripts
	#var max_load = 0
	#for i in object.ram.get_children():
		#if i.cpu_load[cpu] > max_load:
			#scripts.clear()
			#scripts.append(i)
			#max_load = i.cpu_load[cpu]
		#elif i.cpu_load[cpu] == max_load:
			#scripts.append(i)
	#return scripts
#
#func get_dangerous_ram(object: System):
	#var scripts: Array[ScriptLabel]
	#if object.ram.get_child_count() == 0:
		#return scripts
	#var cpus = find_max_loaded_cpus(object)
	#if cpus.is_empty():
		#return scripts
	#if cpus[0].load < 60:
		#return scripts
	#for i in cpus:
		#scripts.append_array(find_scripts_max_loading_cpu(object, i.num))
	#return scripts
#
#func find_cpu_to_break(object: System, subject: System):
	#var max_loaded_cpus = find_max_loaded_cpus_no_vm(object)
	#if !max_loaded_cpus.is_empty():
		#return max_loaded_cpus[randi() % max_loaded_cpus.size()]
	#else:
		#return null
#
#func find_disk_c_scripts_to_break_cpu(object: System, subject: System, cpu: CPUBar):
	#var scripts: Array[ScriptLabel]
	#var min_price = 10
	#for i in object.disk_c.get_children():
		#if i.direction == "attack" and i.type == "load" and i.values and i.values[0].val >= 100 - cpu.load:
			#if i.run_price_cur < min_price:
				#scripts.clear()
				#scripts.append(i)
				#min_price = i.run_price_cur
			#elif i.run_price_cur == min_price:
				#scripts.append(i)
	#if !scripts.is_empty() and min_price > subject.cur_seconds:
		#scripts.clear()
	#return scripts
#
#func find_disk_d_scripts_to_break_cpu(object: System, subject: System, cpu: CPUBar):
	#var scripts: Array[ScriptLabel]
	#var min_price = 10
	#for i in object.disk_d.get_children():
		#if i.direction == "attack" and i.type == "load" and i.values and i.values[0].val >= 100 - cpu.load:
			#if i.copy_price_cur + i.run_price_cur < min_price:
				#scripts.clear()
				#scripts.append(i)
				#min_price = i.copy_price_cur + i.run_price_cur
			#elif i.copy_price_cur + i.run_price_cur == min_price:
				#scripts.append(i)
	#if !scripts.is_empty() and min_price > subject.cur_seconds:
		#scripts.clear()
	#return scripts
#
#func get_scripts(segment: VBoxContainer, direction: String, perm: bool):
	#var scripts: Array[ScriptLabel]
	#for i in segment.get_children():
		#if i is ScriptLabel and i.direction == direction and (!perm or i.turns_to_live == 0):
			#scripts.append(i)
	#return scripts
#
#func reset_state():
	#dangerous_scripts.clear()
	#cpu_to_break = null
	#disk_c_breaking_scripts.clear()
	#disk_d_breaking_scripts.clear()
	#selected_script_id = 0
	#waiting_for_cpu_select = false
	#can_click_disk_d_scripts = true
	#can_click_active_script = true
	#subject_ram_attack_scripts.clear()
	#subject_disk_c_attack_scripts.clear()
	#subject_disk_c_defend_scripts.clear()
	#opponent_disk_c_attack_scripts.clear()
	#total_active_scripts = 0
	#subject_cpu = null
	#opponent_cpu = null
	#last_action = action.NONE
#
#func make_action(subject: System):
	#if waiting_for_cpu_select:
		#match last_action:
			#action.FIND_CPU_TO_BREAK:
				#if !battle.cpu_left_click(subject.opponent, subject, cpu_to_break):
					#battle.stop_select_cpu(subject.opponent)
					#disk_c_breaking_scripts.remove_at(selected_script_id)
				#else:
					#last_action = action.ATEMPT_CPU_BREAK
				#return false
			#action.COPY_DISK_D_BREAKING:
				#if !battle.cpu_left_click(subject.opponent, subject, cpu_to_break):
					#battle.stop_select_cpu(subject.opponent)
				#last_action = action.ATEMPT_CPU_BREAK
				#return false
			#action.GET_ACTIVE_SCRIPTS:
				#var i = selected_script_id
				#if subject_ram_attack_scripts.size() != 0 and i < subject_ram_attack_scripts.size():
					#last_action = action.CLICK_SCRIPT
					#return false
				#i -= subject_ram_attack_scripts.size()
				#if subject_disk_c_attack_scripts.size() != 0 and i < subject_disk_c_attack_scripts.size():
					#last_action = action.CLICK_SCRIPT
					#return false
				#i -= subject_disk_c_attack_scripts.size()
				#if subject_disk_c_defend_scripts.size() != 0 and i < subject_disk_c_defend_scripts.size():
					#if !battle.cpu_left_click(subject, subject, subject_cpu):
						#battle.stop_select_cpu(subject)
						#subject_disk_c_defend_scripts.remove_at(i)
						#total_active_scripts -= 1
					#else:
						#last_action = action.CLICK_SCRIPT
					#return false
				#i -= subject_disk_c_defend_scripts.size()
				#if opponent_disk_c_attack_scripts.size() != 0 and i < opponent_disk_c_attack_scripts.size():
					#if !battle.cpu_left_click(subject.opponent, subject, opponent_cpu):
						#battle.stop_select_cpu(subject)
						#opponent_disk_c_attack_scripts.remove_at(i)
						#total_active_scripts -= 1
					#else:
						#last_action = action.CLICK_SCRIPT
					#return false
	#
	#while true:
		#match last_action:
			#action.NONE:
				#dangerous_scripts = get_dangerous_ram(subject)
				#if dangerous_scripts.is_empty():
					#last_action = action.NO_DANGEROUS_SCRIPTS
				#else:
					#last_action = action.GET_DANGEROUS_SCRIPTS
			#action.GET_DANGEROUS_SCRIPTS, \
			#action.DEL_DANGEROUS_SCRIPTS:
				#if dangerous_scripts.is_empty():
					#last_action = action.NO_DANGEROUS_SCRIPTS
				#else:
					#selected_script_id = randi() % dangerous_scripts.size()
					#if !battle.ram_right_click(subject, subject, dangerous_scripts[selected_script_id]):
						#dangerous_scripts.remove_at(selected_script_id)
					#else:
						#dangerous_scripts.remove_at(selected_script_id)
						#last_action = action.DEL_DANGEROUS_SCRIPTS
						#return false
			#action.NO_DANGEROUS_SCRIPTS:
				#cpu_to_break = find_cpu_to_break(subject.opponent, subject)
				#if cpu_to_break: 
					#last_action = action.ATEMPT_CPU_BREAK
				#else:
					#disk_c_breaking_scripts = find_disk_c_scripts_to_break_cpu(subject.opponent, subject, cpu_to_break)
					#disk_d_breaking_scripts = find_disk_d_scripts_to_break_cpu(subject, subject, cpu_to_break)
					#last_action = action.FIND_CPU_TO_BREAK
			#action.FIND_CPU_TO_BREAK:
				#if disk_c_breaking_scripts.is_empty():
					#last_action = action.ATEMPT_DISK_C_BREAK
				#else:
					#selected_script_id = randi() % disk_c_breaking_scripts.size()
					#if !battle.disk_c_left_click(subject.opponent, subject, disk_c_breaking_scripts[selected_script_id]):
						#disk_c_breaking_scripts.remove_at(selected_script_id)
					#else:
						#if disk_c_breaking_scripts[selected_script_id].select:
							#waiting_for_cpu_select = true
						#else:
							#last_action = action.ATEMPT_CPU_BREAK
						#return false
			#action.ATEMPT_DISK_C_BREAK:
				#if disk_d_breaking_scripts.is_empty():
					#last_action = action.ATEMPT_CPU_BREAK
				#else:
					#selected_script_id = randi() % disk_d_breaking_scripts.size()
					#if !battle.disk_d_left_click(subject, subject, disk_d_breaking_scripts[selected_script_id]):
						#disk_d_breaking_scripts.remove_at(selected_script_id)
					#else:
						#last_action = action.COPY_DISK_D_BREAKING
						#return false
			#action.COPY_DISK_D_BREAKING:
				#if subject.opponent.disk_c.get_child_count() == 0:
					#last_action = action.ATEMPT_CPU_BREAK
				#else:
					#var selected_script = get_last_script(subject.opponent.disk_c)
					#if !battle.disk_c_left_click(subject.opponent, subject, selected_script):
						#last_action = action.ATEMPT_CPU_BREAK
					#else:
						#if selected_script.select:
							#waiting_for_cpu_select = true
						#else:
							#last_action = action.ATEMPT_CPU_BREAK
						#return false
			#action.ATEMPT_CPU_BREAK, \
			#action.CLICK_SCRIPT:
				#if !can_click_disk_d_scripts and !can_click_active_script:
					#return true
				#
				## Find all clickable scripts (excluding Disk D)
				#subject_ram_attack_scripts = get_scripts(subject.ram, "attack", true)
				#subject_disk_c_attack_scripts = get_scripts(subject.disk_c, "attack", false)
				#subject_disk_c_defend_scripts = get_scripts(subject.disk_c, "defend", false)
				#opponent_disk_c_attack_scripts = get_scripts(subject.opponent.disk_c, "attack", false)
				#total_active_scripts = subject_ram_attack_scripts.size() + \
						#subject_disk_c_attack_scripts.size() + \
						#subject_disk_c_defend_scripts.size() + \
						#opponent_disk_c_attack_scripts.size()
				#if total_active_scripts == 0:
					#can_click_active_script = false
				#
				#var active_script_chance: int
				#if total_active_scripts >= 5:
					#active_script_chance = 100
				#else:
					#active_script_chance = total_active_scripts * 20
				#var turn_type_choice = (randi() % 100) + 1
				#
				#if (can_click_disk_d_scripts and !can_click_active_script) or \
						#(can_click_disk_d_scripts and turn_type_choice > active_script_chance):
					#if subject.disk_d.get_child_count() == 0:
						#can_click_disk_d_scripts = false
					#else:
						#var i = randi() % subject.disk_d.get_child_count()
						#var id: int
						#for j in subject.disk_d.get_child_count():
							#id = (i + j) % subject.disk_d.get_child_count()
							#if battle.disk_d_left_click(subject, subject, subject.disk_d.get_child(id)):
								#can_click_active_script = true
								#last_action = action.CLICK_SCRIPT
								#return false
						#can_click_disk_d_scripts = false
				#else:
					## Select subject and opponent CPU
					#var min_loaded_cpus = find_min_loaded_cpus_no_vm(subject)
					#if min_loaded_cpus.is_empty():
						#subject_cpu = null
					#else:
						#subject_cpu = min_loaded_cpus[randi() % min_loaded_cpus.size()]
					#
					#var max_loaded_cpus = find_max_loaded_cpus_no_vm(subject.opponent)
					#if max_loaded_cpus.is_empty():
						#max_loaded_cpus = find_max_loaded_cpus(subject.opponent)
					#if max_loaded_cpus.is_empty():
						#opponent_cpu = null
					#else:
						#opponent_cpu = max_loaded_cpus[randi() % max_loaded_cpus.size()]
					#
					#last_action = action.GET_ACTIVE_SCRIPTS
			#action.GET_ACTIVE_SCRIPTS:
				## Try to click random script
				#while total_active_scripts != 0:
					#selected_script_id = randi() % total_active_scripts
					#var i = selected_script_id
					#if subject_ram_attack_scripts.size() != 0 and i < subject_ram_attack_scripts.size():
						#if !battle.ram_right_click(subject, subject, subject_ram_attack_scripts[i]):
							#subject_ram_attack_scripts.remove_at(i)
							#total_active_scripts -= 1
							#continue
						#else:
							#last_action = action.CLICK_SCRIPT
							#return false
					#i -= subject_ram_attack_scripts.size()
					#if subject_disk_c_attack_scripts.size() != 0 and i < subject_disk_c_attack_scripts.size():
						#if !battle.disk_c_right_click(subject, subject, subject_disk_c_attack_scripts[i]):
							#subject_disk_c_attack_scripts.remove_at(i)
							#total_active_scripts -= 1
							#continue
						#else:
							#last_action = action.CLICK_SCRIPT
							#return false
					#i -= subject_disk_c_attack_scripts.size()
					#if subject_disk_c_defend_scripts.size() != 0 and i < subject_disk_c_defend_scripts.size():
						#if !battle.disk_c_left_click(subject, subject, subject_disk_c_defend_scripts[i]):
							#subject_disk_c_defend_scripts.remove_at(i)
							#total_active_scripts -= 1
							#continue
						#else:
							#if subject_disk_c_defend_scripts[i].select:
								#waiting_for_cpu_select = true
							#else:
								#last_action = action.CLICK_SCRIPT
							#return false
					#i -= subject_disk_c_defend_scripts.size()
					#if opponent_disk_c_attack_scripts.size() != 0 and i < opponent_disk_c_attack_scripts.size():
						#if !battle.disk_c_left_click(subject.opponent, subject, opponent_disk_c_attack_scripts[i]):
							#opponent_disk_c_attack_scripts.remove_at(i)
							#total_active_scripts -= 1
							#continue
						#else:
							#if opponent_disk_c_attack_scripts[i].select:
								#waiting_for_cpu_select = true
							#else:
								#last_action = action.CLICK_SCRIPT
							#return false
					#break
				#can_click_active_script = false
				#last_action = action.CLICK_SCRIPT
				#return false
	#
	#battle.end_turn_click(subject)
