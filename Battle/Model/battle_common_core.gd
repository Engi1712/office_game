class_name BattleCommonCore

enum states {
	BATTLE,
	SHOP,
	OVER
}

enum mouse_buttons {
	LEFT,
	RIGHT
}

enum action_types {
	MAIN,
	SMALL,
	SELECTION,
	NONE
}

enum selection_state {
	NONE,
	ITEM,
	SYSTEM
}

enum results {
	WIN,
	LOSS,
	DRAW,
	NONE
}

# System

enum user_types {
	GUEST,
	ROOT
}

enum sudo_statuses {
	LOCKED,
	UNLOCKED,
	OPEN
}

enum item_types {
	CPU,
	IFACE,
	DISK_D_SCRIPT,
	DISK_C_SCRIPT,
	RAM_SCRIPT,
	SHOP_SCRIPT
}

# Script

enum script_types {
	LOAD,
	UTILITY,
	VM,
	ANTIVIRUS,
	PROTECTOR,
	MINER,
	KEY,
	TRAFFIC,
	BREAKER,
	CLEANER,
	BOOSTER,
	JAMMER,
	LEGENDARY
}

enum price_types {
	COPY,
	DELETE,
	RUN,
	STOP
}

enum locations {
	DISK_D,
	DISK_C,
	RAM
}

# CPU

enum cpu_types {
	AVAIL_REAL,
	REAL,
	CUR,
	ALL
}

enum cpu_states {
	WAITING,
	ACTIVE,
	BROKEN
}

# Modifier

enum operations {
	ADD_PERCENT,
	DEC_PERCENT,
	ADD_FLAT,
	DEC_FLAT,
	MAX,
	MIN
}

# Token

enum tokens {
	CORTEX,
	DATAWEAVE,
	PETRICHOR,
	LOOM,
	FRACTAL,
	TAUCOIN
}

# Bounty

enum bounty_types {
	NONE,
	HIGH,
	LOW
}

class volatile_value:
	var cur_val: int = 0
	var max_val: int = 0
	
	func add(delta: int):
		if cur_val + delta < 0:
			cur_val = 0
		elif cur_val + delta > max_val:
			cur_val = max_val
		else:
			cur_val += delta

class access_matrix:
	var type: user_types
	var disk_d_lmb: bool
	var disk_d_rmb: bool
	var disk_c_lmb: bool
	var disk_c_rmb: bool
	var ram_lmb: bool
	var ram_rmb: bool
	
	func _init(user: user_types):
		type = user
		match user:
			user_types.GUEST:
				set_access(locations.DISK_D, mouse_buttons.LEFT, false)
				set_access(locations.DISK_D, mouse_buttons.RIGHT, false)
				set_access(locations.DISK_C, mouse_buttons.LEFT, true)
				set_access(locations.DISK_C, mouse_buttons.RIGHT, false)
				set_access(locations.RAM, mouse_buttons.LEFT, false)
				set_access(locations.RAM, mouse_buttons.RIGHT, false)
			user_types.ROOT:
				set_access(locations.DISK_D, mouse_buttons.LEFT, true)
				set_access(locations.DISK_D, mouse_buttons.RIGHT, false)
				set_access(locations.DISK_C, mouse_buttons.LEFT, true)
				set_access(locations.DISK_C, mouse_buttons.RIGHT, true)
				set_access(locations.RAM, mouse_buttons.LEFT, false)
				set_access(locations.RAM, mouse_buttons.RIGHT, true)
	
	func get_access(loc: locations, mb: mouse_buttons):
		match mb:
			mouse_buttons.LEFT:
				match loc:
					locations.DISK_D:
						return disk_d_lmb
					locations.DISK_C:
						return disk_c_lmb
					locations.RAM:
						return ram_lmb
			mouse_buttons.RIGHT:
				match loc:
					locations.DISK_D:
						return disk_d_rmb
					locations.DISK_C:
						return disk_c_rmb
					locations.RAM:
						return ram_rmb
	
	func set_access(loc: locations, mb: mouse_buttons, access: bool):
		match mb:
			mouse_buttons.LEFT:
				match loc:
					locations.DISK_D:
						disk_d_lmb = access
					locations.DISK_C:
						disk_c_lmb = access
					locations.RAM:
						ram_lmb = access
			mouse_buttons.RIGHT:
				match loc:
					locations.DISK_D:
						disk_d_rmb = access
					locations.DISK_C:
						disk_c_rmb = access
					locations.RAM:
						ram_rmb = access
	
	func get_action_name(loc: locations, mb: mouse_buttons):
		match mb:
			mouse_buttons.LEFT:
				match loc:
					locations.DISK_D:
						if disk_d_lmb:
							return "copy"
					locations.DISK_C:
						if disk_c_lmb:
							return "run"
			mouse_buttons.RIGHT:
				match loc:
					locations.DISK_C:
						if disk_c_rmb:
							return "delete"
					locations.RAM:
						if ram_rmb:
							return "stop"
		return "blank"

class token_storage:
	var cortex = volatile_value.new()
	var dataweave = volatile_value.new()
	var petrichor = volatile_value.new()
	var loom = volatile_value.new()
	var fractal = volatile_value.new()
	var taucoin = volatile_value.new()
	
	func get_token(token: tokens):
		match token:
			tokens.CORTEX:
				return cortex
			tokens.DATAWEAVE:
				return dataweave
			tokens.PETRICHOR:
				return petrichor
			tokens.LOOM:
				return loom
			tokens.FRACTAL:
				return fractal
			tokens.TAUCOIN:
				return taucoin
	
	func set_token_cur(token: tokens, val: int):
		get_token(token).cur_val = val
	
	func set_token_max(token: tokens, val: int):
		get_token(token).max_val = val

class script_per_cpu:
	var selected: bool = false
	var cur_load: int = 0
	var max_load: int = 0
	var num_of_mod: int = 0
	var mod_id: int = -1
	var cpu_node: CPUBarCore = null
	
	func select(cpu: CPUBarCore):
		selected = true
		cpu_node = cpu
	
	func deselect():
		selected = false
		cpu_node = null
		max_load = 0
		num_of_mod = 0
		mod_id = -1

class script_per_iface:
	var selected: bool = false
	var cur_traffic: int = 0
	var max_traffic: int = 0
	var iface_node: NetInterfaceCore = null
	
	func _init(p_iface_node: NetInterfaceCore):
		iface_node = p_iface_node

class load_mod:
	var id: int
	var op: operations
	var val: int
	var source: ScriptFileCore
	var scripts_affected: Array[script_per_cpu]
	
	func _init(p_id: int, p_op: operations, p_val: int, p_source: ScriptFileCore):
		id = p_id
		op = p_op
		val = p_val
		source = p_source

class item_group:
	var object: SystemCore
	var type: item_types
	
	func _init(p_object: SystemCore, p_type: item_types):
		object = p_object
		type = p_type
