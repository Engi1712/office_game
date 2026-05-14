class_name BattleManagerCore

var battle: Battle
var lower_system: SystemCore
var upper_system: SystemCore
var current_system: SystemCore
var current_state: BattleCommonCore.states
var winners: Array[SystemCore]

var view: Control

func _init(lower_player: PlayerSpecs, upper_player: PlayerSpecs):
	battle = Battle.new()
	lower_system = SystemCore.new(lower_player)
	upper_system = SystemCore.new(upper_player)
	upper_system.opponent = lower_system
	lower_system.opponent = upper_system
	select_as_first(lower_system)
	current_state = BattleCommonCore.states.BATTLE

# --- Public ---

func back(subject: SystemCore):
	if current_system != subject:
		return false
	
	match current_state:
		BattleCommonCore.states.BATTLE:
			if !battle.check_if_idle():
				battle.idle()
				return true
		BattleCommonCore.states.SHOP:
			current_system.shop.close()
			current_state = BattleCommonCore.states.BATTLE
			return true
	return false

# Battle functions

func battle_interact(item: ItemCore, type: BattleCommonCore.mouse_buttons, subject: SystemCore):
	if current_system != subject:
		return BattleCommonCore.action_types.NONE
	if current_state != BattleCommonCore.states.BATTLE:
		return BattleCommonCore.action_types.NONE
	
	var res = battle.click_manager(item, type, current_system)
	check_game_over()
	return res

func battle_select_system(object: SystemCore, subject: SystemCore):
	if current_system != subject:
		return BattleCommonCore.action_types.NONE
	if current_state != BattleCommonCore.states.BATTLE:
		return BattleCommonCore.action_types.NONE
	
	var res = battle.click_system(object, subject)
	return res

func battle_end_turn(subject: SystemCore):
	if current_system != subject:
		return false
	if current_state != BattleCommonCore.states.BATTLE:
		return false
	
	var res = battle.click_end_turn(current_system)
	check_game_over()
	current_system = current_system.opponent
	return res

# Shop functions

func toggle_shop(subject: SystemCore):
	if current_system != subject:
		return false
	
	match current_state:
		BattleCommonCore.states.BATTLE:
			current_system.shop.open()
			current_state = BattleCommonCore.states.SHOP
			return true
		BattleCommonCore.states.SHOP:
			current_system.shop.close()
			current_state = BattleCommonCore.states.BATTLE
			return true
	return false

func shop_interact(script_file: ScriptFileCore, subject: SystemCore):
	if current_system != subject:
		return false
	if current_state != BattleCommonCore.states.SHOP:
		return false
	
	return current_system.shop.select_script(script_file)

func shop_buy_script(subject: SystemCore):
	if current_system != subject:
		return false
	if current_state != BattleCommonCore.states.SHOP:
		return false
	
	return current_system.shop.buy_selected()

func is_shop_active():
	return current_state == BattleCommonCore.states.SHOP

func is_over():
	return current_state == BattleCommonCore.states.OVER

# --- Private ---

func check_game_over():
	var game_over = battle.check_for_end(current_system)
	match game_over:
		BattleCommonCore.results.WIN:
			winners.append(current_system)
			wrap_up()
		BattleCommonCore.results.LOSS:
			winners.append(current_system.opponent)
			wrap_up()
		BattleCommonCore.results.DRAW:
			winners.append(current_system)
			winners.append(current_system.opponent)
			wrap_up()

func wrap_up():
	current_state = BattleCommonCore.states.OVER
	current_system.set_inactive_abrupt()
	current_system = null

func select_as_first(subject: SystemCore):
	subject.set_active()
	subject.set_first()
	current_system = subject
