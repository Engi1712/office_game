extends Control

@onready var battle_field = $BattleField
@onready var shop_menu = $ShopMenu
@onready var pause_menu = $PauseMenu
@onready var game_over_menu = $GameOver
@onready var show_tooltip_timer = $ShowTooltipTimer
@onready var hide_tooltip_timer = $HideTooltipTimer
@onready var click_sfx = $ClickSFX
@onready var press_sfx = $PressSFX
@onready var buy_sfx = $BuySFX

var model: BattleManagerCore

var lower_system: System
var upper_system: System
var lower_shop: Shop
var upper_shop: Shop

var current_interactor: SystemCore
var current_mode: BattleCommon.modes
var two_interactors: bool

var paused: bool = false
var over: bool = false

var current_tooltip: Tooltip
var next_tooltip: Tooltip

func _ready():
	# Set everything up
	var lower_player_param = load("res://Battle/Container/Players/" + MenuSwitcher.get_param("lower_player") + ".tres")
	var upper_player_param = load("res://Battle/Container/Players/" + MenuSwitcher.get_param("upper_player") + ".tres")
	current_mode = MenuSwitcher.get_param("mode")
	model = BattleManagerCore.new(lower_player_param, upper_player_param)
	lower_system = battle_field.prepare_lower(lower_player_param, model.lower_system)
	upper_system = battle_field.prepare_upper(upper_player_param, model.upper_system)
	lower_shop = shop_menu.prepare_lower(model.lower_system.shop)
	upper_shop = shop_menu.prepare_upper(model.upper_system.shop)
	
	# Select interactors
	if current_mode == BattleCommon.modes.HOT_SEAT:
		two_interactors = true
		upper_system.set_interactible()
	else:
		two_interactors = false
	lower_system.set_interactible()
	current_interactor = model.current_system
	
	# Connect signals
	upper_system.item_added.connect(_on_item_added.bind(BattleCommon.window_types.BATTLE))
	lower_system.item_added.connect(_on_item_added.bind(BattleCommon.window_types.BATTLE))
	upper_shop.item_added.connect(_on_item_added.bind(BattleCommon.window_types.SHOP))
	lower_shop.item_added.connect(_on_item_added.bind(BattleCommon.window_types.SHOP))
	upper_system.disk_c_selected.connect(_on_disk_c_clicked.bind(upper_system.model))
	lower_system.disk_c_selected.connect(_on_disk_c_clicked.bind(lower_system.model))
	show_tooltip_timer.timeout.connect(show_tooltip)
	hide_tooltip_timer.timeout.connect(hide_tooltip)
	battle_field.end_turn_button_pressed.connect(_on_battle_end_turn_button_pressed)
	shop_menu.buy_button_pressed.connect(_on_shop_buy_button_pressed)
	pause_menu.resume_button_pressed.connect(_on_pause_menu_resume_button_pressed)
	pause_menu.restart_button_pressed.connect(_on_pause_menu_restart_button_pressed)
	pause_menu.exit_button_pressed.connect(_on_pause_menu_exit_button_pressed)
	game_over_menu.new_game_button_pressed.connect(_on_game_over_menu_new_game_button_pressed)
	game_over_menu.exit_button_pressed.connect(_on_game_over_menu_exit_button_pressed)
	
	update_full()

# Signal callbacks

func _input(event: InputEvent):
	if over:
		return
	if event.is_action_pressed("menu"):
		back(current_interactor)
	elif event.is_action_pressed("inv"):
		toggle_shop(current_interactor)

func _on_item_added(item: Control, window_type: BattleCommon.window_types):
	item.gui_input.connect(_on_item_interacted.bind(item.model, window_type))
	item.mouse_entered.connect(_on_item_hover.bind(item))
	item.mouse_exited.connect(_on_item_dehover.bind(item))

func _on_item_interacted(event: InputEvent, item: ItemCore, window_type: BattleCommon.window_types):
	if event is InputEventMouseButton and event.pressed:
		var type: BattleCommonCore.mouse_buttons
		if event.button_index == MOUSE_BUTTON_LEFT:
			type = BattleCommonCore.mouse_buttons.LEFT
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			type = BattleCommonCore.mouse_buttons.RIGHT
		else:
			return
		if window_type == BattleCommon.window_types.BATTLE:
			battle_interact(item, type, current_interactor)
		elif window_type == BattleCommon.window_types.SHOP and type == BattleCommonCore.mouse_buttons.LEFT:
			shop_interact(item, current_interactor)

func _on_disk_c_clicked(object: SystemCore):
	if model.battle_select_system(object, current_interactor) == BattleCommonCore.action_types.SMALL:
		click_sfx.play()
		update_small()

func _on_battle_end_turn_button_pressed():
	battle_end_turn(current_interactor)

func _on_shop_buy_button_pressed():
	shop_buy_script(current_interactor)

func _on_pause_menu_resume_button_pressed():
	close_pause_menu()

func _on_pause_menu_restart_button_pressed():
	restart()

func _on_pause_menu_exit_button_pressed():
	exit()

func _on_game_over_menu_new_game_button_pressed():
	restart()

func _on_game_over_menu_exit_button_pressed():
	exit()

# Interface with graphic updates

func battle_interact(item: ItemCore, type: BattleCommonCore.mouse_buttons, subject: SystemCore):
	match model.battle_interact(item, type, subject):
		BattleCommonCore.action_types.MAIN:
			click_sfx.play()
			update_full()
		BattleCommonCore.action_types.SMALL:
			click_sfx.play()
			update_small()
		BattleCommonCore.action_types.SELECTION:
			click_sfx.play()
			update_selection()
	if model.is_over():
		current_interactor = null
		over = true
		open_game_over()

func battle_end_turn(subject: SystemCore):
	if model.battle_end_turn(subject):
		press_sfx.play()
		update_full()
		if two_interactors:
			current_interactor = current_interactor.opponent
		if model.is_over():
			current_interactor = null
			open_game_over()

func shop_interact(script_file: ScriptFileCore, subject: SystemCore):
	if model.shop_interact(script_file, subject):
		click_sfx.play()
		subject.shop.view.update_selection()

func shop_buy_script(subject: SystemCore):
	if model.shop_buy_script(subject):
		buy_sfx.play()
		update_small()
		subject.shop.view.update_full()

func back(subject: SystemCore):
	if paused:
		close_pause_menu()
	else:
		var was_shop_open = model.is_shop_active()
		if model.back(subject):
			if was_shop_open and !model.is_shop_active():
				close_shop_menu()
			else:
				update_selection()
		else:
			open_pause_menu()
			paused = true

func toggle_shop(subject: SystemCore):
	if model.toggle_shop(subject):
		if model.is_shop_active():
			open_shop_menu()
		else:
			close_shop_menu()

# Game handling

func restart():
	get_tree().reload_current_scene()

func exit():
	MenuSwitcher.switch("main_menu")

# Update

func update_full():
	lower_system.update_full()
	lower_shop.update_full()
	upper_system.update_full()
	upper_shop.update_full()

func update_small():
	lower_system.update_small()
	upper_system.update_small()

func update_selection():
	lower_system.update_selection()
	upper_system.update_selection()

# Submenu switching functions

func open_shop_menu():
	battle_field.pause()
	shop_menu.open()

func close_shop_menu():
	shop_menu.close()
	battle_field.resume()

func open_pause_menu():
	battle_field.pause()
	pause_menu.open()

func close_pause_menu():
	pause_menu.close()
	battle_field.resume()

func open_game_over():
	battle_field.pause()
	game_over_menu.open(model.winners, current_mode)

# Hover functions

func _on_item_hover(item: Control):
	item.hover()
	set_tooltip(item)

func _on_item_dehover(item: Control):
	item.dehover()
	reset_tooltip(item)

func set_tooltip(active_node: Control):
	hide_tooltip_timer.stop()
	if current_tooltip and active_node.tooltip != current_tooltip:
		current_tooltip.make_transparent()
		current_tooltip = active_node.tooltip
		current_tooltip.update_position()
		current_tooltip.make_opaque()
	else:
		next_tooltip = active_node.tooltip
		show_tooltip_timer.start()

func reset_tooltip(_active_node: Control):
	show_tooltip_timer.stop()
	hide_tooltip_timer.start()

func show_tooltip():
	current_tooltip = next_tooltip
	current_tooltip.update_position()
	current_tooltip.make_opaque()

func hide_tooltip():
	if !current_tooltip:
		return
	current_tooltip.make_transparent()
	current_tooltip = null
