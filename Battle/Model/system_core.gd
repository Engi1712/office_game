class_name SystemCore

var cpus: Array[CPUBarCore]
var vcpus: Array[CPUBarCore]
var ifaces: Array[NetInterfaceCore]
var disk_d_scripts: Array[ScriptFileCore]
var disk_c_scripts: Array[ScriptFileCore]
var ram_scripts: Array[ScriptFileCore]
var limbo_scripts: Array[ScriptFileCore]

var max_disk_c_scripts: int = 10

var disk_e_tokens = BattleCommonCore.token_storage.new()

var max_seconds: int = 90
var cur_seconds: int
var cur_taucoin_inc: int = 0
var sudo = BattleCommonCore.sudo_statuses.LOCKED

var taucoin_stolen: bool = false
var script_bought: bool = false
var active: bool = false
var upper: bool

var opponent: SystemCore
var shop: ShopCore

var copy_price_mod: int
var delete_price_mod: int
var run_price_mod: int
var stop_price_mod: int

var disk_c_highlighted: bool = false

var bounty_cur_turn: int = -1
var bounty_active_turns: int = 3
var high_bounty_cpu: CPUBarCore
var low_bounty_cpu: CPUBarCore
var bounty_secured: bool = false

var guest_am = BattleCommonCore.access_matrix.new(BattleCommonCore.user_types.GUEST)
var root_am = BattleCommonCore.access_matrix.new(BattleCommonCore.user_types.ROOT)

var view: Control

func _init(player_data: PlayerSpecs):
	shop = ShopCore.new(self)
	for i in range(player_data.cpu_num):
		add_cpu(i)
	for i in range(player_data.iface_num):
		add_iface(i)
	for i in player_data.scripts.general:
		add_disk_d_script(i.resource_path, self)
	for i in player_data.scripts.shop:
		add_shop_script(i.resource_path)
	refill_seconds()
	disk_e_tokens.set_token_max(BattleCommonCore.tokens.CORTEX, 30)
	disk_e_tokens.set_token_max(BattleCommonCore.tokens.DATAWEAVE, 30)
	disk_e_tokens.set_token_max(BattleCommonCore.tokens.PETRICHOR, 30)
	disk_e_tokens.set_token_max(BattleCommonCore.tokens.LOOM, 30)
	disk_e_tokens.set_token_max(BattleCommonCore.tokens.FRACTAL, 30)
	disk_e_tokens.set_token_max(BattleCommonCore.tokens.TAUCOIN, 2000)
	# Debug
	disk_e_tokens.set_token_cur(BattleCommonCore.tokens.CORTEX, 1)
	disk_e_tokens.set_token_cur(BattleCommonCore.tokens.DATAWEAVE, 1)
	disk_e_tokens.set_token_cur(BattleCommonCore.tokens.PETRICHOR, 1)
	# -----

# --- Public ---

func set_first():
	cur_seconds = max_seconds / 2

func set_active():
	if active:
		return
	active = true
	lock_sudo()
	refill_seconds()
	step_bounty()
	shop.set_active()

func set_inactive():
	if !active:
		return
	active = false
	open_sudo()
	get_taucoin()
	restore_taucoin()
	secure_bounty()
	shop.set_inactive()

func set_inactive_abrupt():
	if !active:
		return
	active = false
	shop.set_inactive()

func is_active():
	return active

func add_cpu(cpu_id: int):
	var new_cpu = CPUBarCore.new(cpu_id, false, 100)
	cpus.append(new_cpu)
	var new_vcpu = CPUBarCore.new(cpu_id, true, 0)
	vcpus.append(new_vcpu)
	new_cpu.vm = new_vcpu
	return new_cpu

func add_iface(iface_id: int):
	var new_iface = NetInterfaceCore.new(iface_id)
	if upper:
		new_iface.iface_name = "ens"
	else:
		new_iface.iface_name = "enp"
	ifaces.append(new_iface)
	return new_iface

func add_disk_d_script(script_name: String, subject: SystemCore):
	var new_script_node = ScriptFileCore.new(script_name, self, subject, BattleCommonCore.item_types.DISK_D_SCRIPT)
	disk_d_scripts.append(new_script_node)
	return new_script_node

func del_disk_d_script(script_file: ScriptFileCore):
	for i in range(disk_d_scripts.size()):
		if disk_d_scripts[i] == script_file:
			disk_d_scripts.remove_at(i)
			script_file.dead = true
			break

func add_disk_c_script(script_name: String, subject: SystemCore):
	var new_script_node = ScriptFileCore.new(script_name, self, subject, BattleCommonCore.item_types.DISK_C_SCRIPT)
	disk_c_scripts.append(new_script_node)
	return new_script_node

func del_disk_c_script(script_file: ScriptFileCore):
	if script_file.related_label:
		script_file.related_label.related_label = null
	for i in range(disk_c_scripts.size()):
		if disk_c_scripts[i] == script_file:
			disk_c_scripts.remove_at(i)
			script_file.dead = true
			break

func add_ram_script(script_file: ScriptFileCore, subject: SystemCore):
	var new_script_file = ScriptFileCore.new(script_file.resource_name, self, subject, BattleCommonCore.item_types.RAM_SCRIPT)
	ram_scripts.append(new_script_file)
	script_file.available = false
	script_file.related_label = new_script_file
	new_script_file.related_label = script_file
	return new_script_file

func del_ram_script(script_file: ScriptFileCore):
	if script_file.related_label:
		script_file.related_label.available = true
		script_file.related_label.related_label = null
	for i in range(ram_scripts.size()):
		if ram_scripts[i] == script_file:
			ram_scripts.remove_at(i)
			script_file.dead = true
			break

func move_script_to_limbo(script_file: ScriptFileCore):
	if script_file.related_label:
		script_file.related_label.available = true
		script_file.related_label.related_label = null
	for i in range(ram_scripts.size()):
		if ram_scripts[i] == script_file:
			ram_scripts.remove_at(i)
			limbo_scripts.append(script_file)
			script_file.dead = true
			break

func del_limbo_script(script_file: ScriptFileCore):
	for i in range(limbo_scripts.size()):
		if limbo_scripts[i] == script_file:
			limbo_scripts.remove_at(i)
			break

func add_shop_script(script_name: String):
	return shop.add_script(script_name)

func add_price_mod(type: BattleCommonCore.price_types, delta: int):
	match type:
		BattleCommonCore.price_types.COPY:
			copy_price_mod += delta
		BattleCommonCore.price_types.DELETE:
			delete_price_mod += delta
		BattleCommonCore.price_types.RUN:
			run_price_mod += delta
		BattleCommonCore.price_types.STOP:
			stop_price_mod += delta

func add_vm(cpu_id: int, max_load: int):
	vcpus[cpu_id].max_load = max_load
	vcpus[cpu_id].set_active()
	cpus[cpu_id].has_vm = true

func del_vm(cpu_id):
	vcpus[cpu_id].set_inactive()
	cpus[cpu_id].has_vm = false

func get_cpus(type: BattleCommonCore.cpu_types, exclude_items: Array[ItemCore] = []):
	var cpu_list: Array[ItemCore] = []
	for i in cpus:
		if i.status != BattleCommonCore.cpu_states.ACTIVE:
			continue
		match type:
			BattleCommonCore.cpu_types.AVAIL_REAL:
				if !i.has_vm:
					append_with_check(cpu_list, i, exclude_items)
			BattleCommonCore.cpu_types.REAL:
				append_with_check(cpu_list, i, exclude_items)
			BattleCommonCore.cpu_types.CUR:
				if i.has_vm and i.vm.status == BattleCommonCore.cpu_states.ACTIVE:
					append_with_check(cpu_list, i.vm, exclude_items)
				else:
					append_with_check(cpu_list, i, exclude_items)
			BattleCommonCore.cpu_types.ALL:
				append_with_check(cpu_list, i, exclude_items)
				if i.has_vm and i.vm.status == BattleCommonCore.cpu_states.ACTIVE:
					append_with_check(cpu_list, i.vm, exclude_items)
	return cpu_list

func get_ifaces(exclude_items: Array[ItemCore] = []):
	var iface_list: Array[ItemCore] = []
	for i in ifaces:
		if i.cur_traffic != i.max_traffic:
			append_with_check(iface_list, i, exclude_items)
	return iface_list

func get_disk_d_scripts(exclude_items: Array[ItemCore] = []):
	var script_list: Array[ItemCore] = []
	for i in disk_d_scripts:
		append_with_check(script_list, i, exclude_items)
	return script_list

func highlight_cpus(type: BattleCommonCore.cpu_types, exclude_items: Array[ItemCore] = []):
	for i in get_cpus(type, exclude_items):
		i.highlighted = true

func idle_cpus():
	for i in vcpus:
		i.highlighted = false
	for i in cpus:
		i.highlighted = false

func highlight_ifaces(exclude_items: Array[ItemCore] = []):
	for i in get_ifaces(exclude_items):
		i.highlighted = true

func idle_ifaces():
	for i in ifaces:
		i.highlighted = false

func highlight_disk_d_scripts(exclude_items: Array[ItemCore] = []):
	for i in get_disk_d_scripts(exclude_items):
		i.highlighted = true

func idle_disk_d_scripts():
	for i in disk_d_scripts:
		i.highlighted = false

func highlight_disk_c():
	disk_c_highlighted = true

func idle_disk_c():
	disk_c_highlighted = false

func is_disk_c_hihlighted():
	return disk_c_highlighted

func check_permission(subject: SystemCore, loc: BattleCommonCore.locations, mb: BattleCommonCore.mouse_buttons):
	if subject == self or sudo == BattleCommonCore.sudo_statuses.OPEN:
		return root_am.get_access(loc, mb)
	else:
		return guest_am.get_access(loc, mb)

func check_price(script_file: ScriptFileCore, price_type: BattleCommonCore.price_types):
	return cur_seconds >= script_file.get_cur_price(price_type)

func dec_price(script_file: ScriptFileCore, price_type: BattleCommonCore.price_types):
	cur_seconds -= script_file.get_cur_price(price_type)

func check_if_sudo_locked():
	if sudo == BattleCommonCore.sudo_statuses.LOCKED:
		return true
	else:
		return false

func unlock_sudo():
	sudo = BattleCommonCore.sudo_statuses.UNLOCKED

func check_token(token: BattleCommonCore.tokens, value: int):
	return disk_e_tokens.get_token(token).cur_val >= value

func get_token(token: BattleCommonCore.tokens):
	return disk_e_tokens.get_token(token).cur_val

func add_token(token: BattleCommonCore.tokens, delta: int):
	disk_e_tokens.get_token(token).add(delta)

func dec_token(token: BattleCommonCore.tokens, delta: int):
	add_token(token, -delta)

func check_if_taucoin_stolen():
	if !taucoin_stolen:
		return true
	else:
		return false

func steal_taucoin():
	taucoin_stolen = true

func calc_taucoin_inc():
	cur_taucoin_inc = 0
	for i in cpus:
		if i.status != BattleCommonCore.cpu_states.ACTIVE:
			continue
		cur_taucoin_inc += i.cur_load

func get_all_ram_scripts_for_owner(subject: SystemCore):
	var res_scripts = []
	for i in ram_scripts:
		if i.owner_system == subject:
			res_scripts.append(i)
	return res_scripts

# --- Private ---

func append_with_check(dst: Array[ItemCore], target: ItemCore, check_list: Array[ItemCore]):
	for i in check_list:
		if target == i:
			return
	dst.append(target)

func get_taucoin():
	if !taucoin_stolen:
		add_token(BattleCommonCore.tokens.TAUCOIN, cur_taucoin_inc)
	else:
		opponent.add_token(BattleCommonCore.tokens.TAUCOIN, cur_taucoin_inc)

func restore_taucoin():
	if taucoin_stolen:
		taucoin_stolen = false

func refill_seconds():
	cur_seconds = max_seconds

func step_bounty():
	bounty_cur_turn += 1
	if bounty_cur_turn > bounty_active_turns:
		bounty_cur_turn = -1
		high_bounty_cpu.set_bounty(BattleCommonCore.bounty_types.NONE)
		high_bounty_cpu = null
		low_bounty_cpu.set_bounty(BattleCommonCore.bounty_types.NONE)
		low_bounty_cpu = null
		bounty_secured = false
	elif bounty_cur_turn == 1:
		var cpu_list = get_cpus(BattleCommonCore.cpu_types.REAL)
		if cpu_list.is_empty():
			return
		var bounty_high = randi() % cpu_list.size()
		high_bounty_cpu = cpu_list[bounty_high]
		high_bounty_cpu.set_bounty(BattleCommonCore.bounty_types.HIGH)
		if cpu_list.size() > 1:
			var bounty_low = randi() % (cpu_list.size() - 1)
			if bounty_low >= bounty_high:
				bounty_low += 1
			low_bounty_cpu = cpu_list[bounty_low]
			low_bounty_cpu.set_bounty(BattleCommonCore.bounty_types.LOW)

func secure_bounty():
	if bounty_cur_turn != bounty_active_turns:
		return
	bounty_secured = true
	var high_bounty_val = 0
	var low_bounty_val = 0
	if high_bounty_cpu.status == BattleCommonCore.cpu_states.ACTIVE:
		high_bounty_val = high_bounty_cpu.cur_load / 10
	if low_bounty_cpu.status == BattleCommonCore.cpu_states.ACTIVE:
		low_bounty_val = low_bounty_cpu.cur_load / 10
	add_token(BattleCommonCore.tokens.LOOM, high_bounty_val - low_bounty_val)

func open_sudo():
	if sudo == BattleCommonCore.sudo_statuses.UNLOCKED:
		sudo = BattleCommonCore.sudo_statuses.OPEN

func lock_sudo():
	if sudo == BattleCommonCore.sudo_statuses.OPEN:
		sudo = BattleCommonCore.sudo_statuses.LOCKED
