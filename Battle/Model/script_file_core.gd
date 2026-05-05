class_name ScriptFileCore extends ItemCore

var script_name: String

var copy_price: int
var delete_price: int
var run_price: int
var stop_price: int

var direction: BattleCommonCore.script_directions
var type: BattleCommonCore.script_types
var selections: Array[ScriptSelect]
var shop_price: int
var cpu_bound: bool
var auto_deleted: bool
var broken: bool = false
var values: Array[ScriptValue]
var resource_name: String

var related_label: ScriptFileCore
var available: bool = true

var cpus: Array[BattleCommonCore.script_per_cpu]
var ifaces: Array[BattleCommonCore.script_per_iface]
var opp_ifaces: Array[BattleCommonCore.script_per_iface]

var traffic_total: int
var traffic_left: int

var payload: ItemCore

var location: BattleCommonCore.locations

var turns_to_live: int
var turns_left: int

func _init(p_resource_name: String, object: SystemCore, subject: SystemCore, p_item_type: BattleCommonCore.item_types):
	resource_name = p_resource_name
	location_system = object
	owner_system = subject
	item_type = p_item_type
	var script_specs = load(resource_name)
	copy_price = script_specs.copy_price
	delete_price = script_specs.delete_price
	run_price = script_specs.run_price
	stop_price = script_specs.stop_price
	direction = script_specs.direction
	type = script_specs.type
	selections = script_specs.select.duplicate()
	turns_to_live = script_specs.temporary
	turns_left = script_specs.temporary
	shop_price = script_specs.shop_price
	cpu_bound = script_specs.cpu_bound
	auto_deleted = script_specs.auto_deleted
	values = script_specs.values.duplicate()
	script_name = script_specs.script_name
	if item_type == BattleCommonCore.item_types.RAM_SCRIPT:
		for i in location_system.cpus:
			cpus.append(BattleCommonCore.script_per_cpu.new())
		for i in location_system.ifaces:
			ifaces.append(BattleCommonCore.script_per_iface.new(i))
		for i in location_system.opponent.ifaces:
			opp_ifaces.append(BattleCommonCore.script_per_iface.new(i))
	match item_type:
		BattleCommonCore.item_types.DISK_D_SCRIPT:
			location = BattleCommonCore.locations.DISK_D
		BattleCommonCore.item_types.DISK_C_SCRIPT:
			location = BattleCommonCore.locations.DISK_C
		BattleCommonCore.item_types.RAM_SCRIPT:
			location = BattleCommonCore.locations.RAM

# --- Public ---

func select_cpu(cpu: CPUBarCore):
	cpus[cpu.id].select(cpu)

func select_iface(iface_id: int):
	ifaces[iface_id].selected = true

func select_opp_iface(iface_id: int):
	opp_ifaces[iface_id].selected = true

func set_max_load(cpu: CPUBarCore, p_max_load: int):
	cpus[cpu.id].select(cpu)
	cpus[cpu.id].max_load = p_max_load
	cpu.set_script_modifiers(cpus[cpu.id])

func set_max_traffic(iface_id: int, max_traffic: int):
	select_iface(iface_id)
	ifaces[iface_id].max_traffic = max_traffic

func set_opp_max_traffic(iface_id: int, max_traffic: int):
	select_opp_iface(iface_id)
	opp_ifaces[iface_id].max_traffic = max_traffic

func set_total_traffic(p_traffic_total: int):
	traffic_total = p_traffic_total
	traffic_left = traffic_total

func set_payload(p_payload: ItemCore):
	payload = p_payload

func get_selected_cpus():
	var selected_cpus = []
	for i in cpus:
		if i.selected:
			selected_cpus.append(i.cpu_node)
	return selected_cpus

func get_cur_price(price_type: BattleCommonCore.price_types):
	match price_type:
		BattleCommonCore.price_types.COPY:
			return calc_price(copy_price, owner_system.copy_price_mod)
		BattleCommonCore.price_types.DELETE:
			return calc_price(delete_price, owner_system.delete_price_mod)
		BattleCommonCore.price_types.RUN:
			return calc_price(run_price, owner_system.run_price_mod)
		BattleCommonCore.price_types.STOP:
			return calc_price(stop_price, owner_system.stop_price_mod)

func get_cur_price_deviation(price_type: BattleCommonCore.price_types):
	match price_type:
		BattleCommonCore.price_types.COPY:
			return get_cur_price(price_type) - copy_price
		BattleCommonCore.price_types.DELETE:
			return get_cur_price(price_type) - delete_price
		BattleCommonCore.price_types.RUN:
			return get_cur_price(price_type) - run_price
		BattleCommonCore.price_types.STOP:
			return get_cur_price(price_type) - stop_price

# --- Private ---

func calc_price(og_price: int, price_mod: int):
	if og_price == 0:
		return 0
	var cur_price = og_price + price_mod
	if cur_price < 1:
		return 1
	elif cur_price > 9:
		return 9
	return cur_price
