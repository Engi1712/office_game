#var battle: Battle
#var run_price_mod: int
#var ram: VBoxContainer
#var disk_d: VBoxContainer
#var disk_c: VBoxContainer
#
#func find_max_loaded_cpus(target: System):
	#pass
#
#func clear_disk_c(object: System):
	#if object.disk_c.get_child_count() == 0:
		#return
	#var amount = randi() % 3
	#for i in amount:
		#var scripts_num = object.disk_c.get_child_count()
		#var selected_script_id = randi() % scripts_num
		#for j in scripts_num:
			#var script = object.disk_c.get_child((selected_script_id + j) % scripts_num)
			#if script is ScriptLabel:
				#if battle.local_disk_c_click("Enemy", script):
					#break
#
#func run_script(target: System, field: System):
	#var enabled_scripts: Array[ScriptLabel]
	#for i in target.disk_c.get_children():
		#if i is ScriptLabel and i.direction == "attack" and i.enabled:
			#enabled_scripts.append(i)
	#if enabled_scripts.is_empty():
		#return false
	#var selected_script_id = randi() % enabled_scripts.size()
	#for i in enabled_scripts.size():
		#var script = enabled_scripts[(selected_script_id + i) % enabled_scripts.size()]
		#if battle.remote_disk_c_click("Enemy", script):
			#if !script.select:
				#return true
			#else:
				#var cpus = find_max_loaded_cpus(target)
				#if cpus.is_empty():
					#return false
				#var random_cpu = randi() % cpus.size()
				#if battle.remote_cpu_click("Enemy", cpus[random_cpu]):
					#return true
	#return false
#
#func copy_and_run_script(target: System, field: System):
	#var max_price = 0
	#var scripts: Array[ScriptLabel]
	#for i in field.disk_d.get_children():
		#if i is ScriptLabel and i.copy_price_cur < field.cur_seconds:
			#if i.copy_price_cur > max_price:
				#scripts.clear()
				#scripts.append(i)
				#max_price = i.copy_price_cur
			#elif i.copy_price_cur == max_price:
				#scripts.append(i)
	#if scripts.is_empty():
		#return false
	#var selected_script_id = randi() % scripts.size()
	#var copied = false
	#for i in scripts.size():
		#var script = scripts[(selected_script_id + i) % scripts.size()]
		#if battle.local_disk_d_click("Enemy", script):
			#copied = true
			#break
	#if !copied:
		#return false
	#if target.disk_c.get_child_count() == 0:
		#return false
	#var new_script = target.disk_c.get_child(target.disk_c.get_child_count() - 1)
	#if new_script is not ScriptLabel:
		#return false
	#if battle.remote_disk_c_click("Enemy", new_script):
		#if !new_script.select:
			#return true
		#else:
			#var cpus = find_max_loaded_cpus(target)
			#if cpus.is_empty():
				#return false
			#var random_cpu = randi() % cpus.size()
			#if battle.remote_cpu_click("Enemy", cpus[random_cpu]):
				#return true
	#return false
#
#func run_price_mod_add(value: int, opponent: System):
	#run_price_mod += value
	#for i in disk_d.get_children():
		#if i is ScriptLabel:
			#i.run_price_mod += value
			#i.update()
	#for i in disk_c.get_children():
		#if i is ScriptLabel and i.direction == "defend":
			#i.run_price_mod += value
			#i.update()
	#for i in ram.get_children():
		#if i is ScriptLabel and i.direction == "defend":
			#i.run_price_mod += value
			#i.update()
	#for i in opponent.disk_c.get_children():
		#if i is ScriptLabel and i.direction == "attack":
			#i.run_price_mod += value
			#i.update()
	#for i in opponent.ram.get_children():
		#if i is ScriptLabel and i.direction == "attack":
			#i.run_price_mod += value
			#i.update()
