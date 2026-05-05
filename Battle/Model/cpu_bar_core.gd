class_name CPUBarCore extends ItemCore

var id: int
var is_vm: bool

var min_load: int = 0
var max_load: int
var cur_load: int

var modifiers: Array[BattleCommonCore.load_mod]
var max_mod_num: int = 5
var cur_mod_num: int = 0

var status: BattleCommonCore.cpu_states

# Real CPUs only
var bounty: BattleCommonCore.bounty_types
var has_vm: bool = false
var vm: CPUBarCore

func _init(p_id: int, p_is_vm: bool, p_max_load: int):
	item_type = BattleCommonCore.item_types.CPU
	id = p_id
	is_vm = p_is_vm
	if !is_vm:
		set_active()
	else:
		set_inactive()
	max_load = p_max_load
	reset_load()

# --- Public ---

func set_active():
	status = BattleCommonCore.cpu_states.ACTIVE

func set_inactive():
	status = BattleCommonCore.cpu_states.WAITING

func add_load(delta: int):
	cur_load += delta
	if cur_load >= max_load:
		status = BattleCommonCore.cpu_states.BROKEN

func reset_load():
	cur_load = min_load

func get_resulting_load(spc: BattleCommonCore.script_per_cpu):
	var res_load = spc.max_load
	for i in range(spc.num_of_mod):
		res_load = apply_modifier(res_load, modifiers[i])
	if cur_load + res_load < min_load:
		res_load = cur_load - min_load
	elif cur_load + res_load > max_load:
		res_load = max_load - cur_load
	return res_load

func set_script_modifiers(spc: BattleCommonCore.script_per_cpu):
	spc.num_of_mod = modifiers.size()
	for i in modifiers:
		i.scripts_affected.append(spc)

func check_if_modifiers_full():
	if modifiers.size() == max_mod_num:
		return true
	else:
		return false

func add_modifier(script_file: ScriptFileCore, op: BattleCommonCore.operations, val: int):
	modifiers.append(BattleCommonCore.load_mod.new(cur_mod_num, op, val, script_file))
	script_file.cpus[id].mod_id = cur_mod_num
	cur_mod_num += 1

func del_modifier(script_file: ScriptFileCore):
	var mod_id = script_file.cpus[id].mod_id
	if mod_id != -1:
		for i in modifiers[mod_id].scripts_affected:
			i.num_of_mod -= 1
		for i in range(mod_id + 1, cur_mod_num):
			modifiers[i].source.cpus[id].mod_id -= 1
		script_file.cpus[id].mod_id = -1
		modifiers.remove_at(mod_id)

func set_bounty(p_bounty: BattleCommonCore.bounty_types):
	bounty = p_bounty

# --- Private ---

func apply_modifier(og_load: int, modifier: BattleCommonCore.load_mod):
	match modifier.op:
		BattleCommonCore.operations.ADD_PERCENT:
			return og_load * (1 + (modifier.val / 100.0))
		BattleCommonCore.operations.DEC_PERCENT:
			return og_load * (1 - (modifier.val / 100.0))
		BattleCommonCore.operations.ADD_FLAT:
			return og_load + modifier.val
		BattleCommonCore.operations.DEC_FLAT:
			if og_load < modifier.val:
				return 0
			return og_load - modifier.val
		BattleCommonCore.operations.MAX:
			if og_load > modifier.val:
				return modifier.val
		BattleCommonCore.operations.MIN:
			if og_load < modifier.val:
				return modifier.val
	return og_load
