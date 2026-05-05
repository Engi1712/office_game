class_name ShopCore

var scripts: Array[ScriptFileCore]
var cur_script: ScriptFileCore
var active: bool = false
var opened: bool = false
var already_bought: bool = false
var owner_system: SystemCore

var view: Control

func _init(object: SystemCore):
	owner_system = object

# --- Public ---

func add_script(script_name: String):
	var new_script_node = ScriptFileCore.new(script_name, owner_system, owner_system, BattleCommonCore.item_types.SHOP_SCRIPT)
	scripts.append(new_script_node)
	return new_script_node

func set_active():
	active = true

func set_inactive():
	active = false

func open():
	if !active:
		return false
	opened = true
	cur_script = null
	return true

func close():
	if !active:
		return false
	opened = false

func select_script(script_node: ScriptFileCore):
	if !opened:
		return false
	if cur_script == script_node:
		cur_script = null
	else:
		cur_script = script_node
	return true

func buy_selected():
	if !opened:
		return false
	if !cur_script:
		return false
	if already_bought:
		return false
	if owner_system.cur_taucoin < cur_script.shop_price:
		return false
	owner_system.add_disk_c_script(cur_script.script_name, owner_system)
	owner_system.cur_taucoin -= cur_script.shop_price
	cur_script = null
	already_bought = true
	return true
