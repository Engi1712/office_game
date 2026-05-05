extends Control

@onready var title_label = $MarginContainer/VBoxContainer/Title
@onready var all_scripts_space = $MarginContainer/VBoxContainer/PlayerScripts/AllScripts/ScrollContainer/VBoxContainer
@onready var selected_scripts_space = $MarginContainer/VBoxContainer/PlayerScripts/SelectedScripts/ScrollContainer/VBoxContainer
@onready var all_shop_scripts_space = $MarginContainer/VBoxContainer/PlayerScripts/AllShopScripts/ScrollContainer/VBoxContainer
@onready var selected_shop_scripts_space = $MarginContainer/VBoxContainer/PlayerScripts/SelectedShopScripts/ScrollContainer/VBoxContainer
@onready var scripts_counter = $MarginContainer/VBoxContainer/PlayerScripts/SelectedScripts/HBoxContainer/Counter
@onready var shop_scripts_counter = $MarginContainer/VBoxContainer/PlayerScripts/SelectedShopScripts/HBoxContainer/Counter
@onready var show_tooltip_timer = $ShowTooltipTimer
@onready var hide_tooltip_timer = $HideTooltipTimer
@onready var ready_button = $MarginContainer/VBoxContainer/HBoxContainer/ReadyButton
@onready var name_edit = $MarginContainer/VBoxContainer/PlayerName/TextEdit
@onready var wallpaper_menu = $MarginContainer/VBoxContainer/PlayerName/OptionButton

var player_id: int

var selected_scripts_num = 0
var selected_shop_scripts_num = 0
var max_scripts_num = 10
var max_shop_scripts_num = 2

var name_entered: bool = false

var current_tooltip: Tooltip
var next_tooltip: Tooltip

const template_script_node = preload("res://Battle/View/script_file.tscn")
const template_tooltip = preload("res://Battle/View/tooltip.tscn")

func _ready():
	player_id = MenuSwitcher.get_param("player_id")
	var title_line: String
	match player_id:
		0:
			title_line = "First player, prepare for battle!"
		1:
			title_line = "Second player, prepare for battle!"
		_:
			title_line = "Error!"
	title_label.text = "[color=" + ColourPalette.yellow + "]" + title_line + "[/color]"
	
	wallpaper_menu.get_popup().transparent_bg = true
	wallpaper_menu.get_popup().canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	
	ready_button.disabled = true
	
	#if BattleData.players[player_id].player_name:
		#name_edit.text = BattleData.players[player_id].player_name
		#name_entered = true
	#for i in BattleData.all_scripts:
		#create_script(i, all_scripts_space, false, false)
	#for i in BattleData.players[player_id].scripts:
		#create_script(i, selected_scripts_space, false, true)
		#all_scripts_space.get_node(i).hide()
		#selected_scripts_num += 1
		#update_scripts_counter()
	#for i in BattleData.all_shop_scripts:
		#create_script(i, all_shop_scripts_space, true, false)
	#for i in BattleData.players[player_id].shop:
		#create_script(i, selected_shop_scripts_space, true, true)
		#all_shop_scripts_space.get_node(i).hide()
		#selected_shop_scripts_num += 1
		#update_shop_scripts_counter()
	check_if_ready()
	
	show_tooltip_timer.timeout.connect(show_tooltip)
	hide_tooltip_timer.timeout.connect(hide_tooltip)
	
	update_scripts_counter()
	update_shop_scripts_counter()

func _on_ready_button_pressed():
	#BattleData.players[player_id].player_name = name_edit.text
	#BattleData.players[player_id].scripts.clear()
	#for i in selected_scripts_space.get_children():
		#BattleData.players[player_id].scripts.append(i.script_name)
	#BattleData.players[player_id].shop.clear()
	#for i in selected_shop_scripts_space.get_children():
		#BattleData.players[player_id].shop.append(i.script_name)
	#if wallpaper_menu.selected == 0:
		#BattleData.players[player_id].wallpaper = wallpaper_menu.get_item_text(randi_range(1, wallpaper_menu.item_count - 1))
	#else:
		#BattleData.players[player_id].wallpaper = wallpaper_menu.get_item_text(wallpaper_menu.selected)
	if player_id == 0:
		MenuSwitcher.switch("player_preparation", {"player_id": 1})
	else:
		MenuSwitcher.switch("battle_field")

func _on_back_button_pressed():
	if player_id == 0:
		MenuSwitcher.switch("main_menu")
	else:
		MenuSwitcher.switch("player_preparation", {"player_id": 0})

func create_script(script_name: String, place: VBoxContainer, shop_script: bool, selected_script: bool):
	var script_specs: ScriptSpecs = load("res://Battle/Scipts/" + script_name + ".tres")
	
	var new_script_node = template_script_node.instantiate()
	new_script_node.name = script_name
	new_script_node.script_name = script_name
	new_script_node.copy_price = script_specs.copy_price
	new_script_node.delete_price = script_specs.delete_price
	new_script_node.run_price = script_specs.run_price
	new_script_node.stop_price = script_specs.stop_price
	new_script_node.direction = script_specs.direction
	new_script_node.type = script_specs.type
	new_script_node.selections = script_specs.select.duplicate()
	new_script_node.turns_to_live = script_specs.temporary
	new_script_node.shop_price = script_specs.shop_price
	new_script_node.auto_deleted = script_specs.auto_deleted
	if shop_script:
		new_script_node.in_shop = true
		new_script_node.can_afford = true
	new_script_node.enabled = true
	new_script_node.values = script_specs.values.duplicate()
	place.add_child(new_script_node)
	
	var new_tooltip = template_tooltip.instantiate()
	new_tooltip.name = "Tooltip"
	new_tooltip.description = script_specs.description
	new_tooltip.upper = false
	new_tooltip.modulate = Color(1, 1, 1, 0)
	new_script_node.tooltip = new_tooltip
	new_tooltip.script_node = new_script_node
	new_script_node.add_child(new_tooltip)
	new_tooltip.prepare()
	new_script_node.update()
	
	new_script_node.gui_input.connect(script_click.bind(new_script_node, shop_script, selected_script))
	new_script_node.mouse_entered.connect(script_mouse_entered.bind(new_script_node))
	new_script_node.mouse_exited.connect(script_mouse_exited.bind(new_script_node))

func script_click(event: InputEvent, script_node: ScriptFile, in_shop: bool, selected: bool):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if selected:
				var og_script: ScriptFile
				if !in_shop:
					og_script = all_scripts_space.get_node(script_node.script_name)
					selected_scripts_num -= 1
					update_scripts_counter()
					check_if_ready()
				else:
					og_script = all_shop_scripts_space.get_node(script_node.script_name)
					selected_shop_scripts_num -= 1
					update_shop_scripts_counter()
					check_if_ready()
				if og_script:
					og_script.show()
				script_node.queue_free()
			else:
				if !in_shop:
					if selected_scripts_num == max_scripts_num:
						return
					create_script(script_node.script_name, selected_scripts_space, false, true)
					selected_scripts_num += 1
					update_scripts_counter()
					check_if_ready()
				else:
					if selected_shop_scripts_num == max_shop_scripts_num:
						return
					create_script(script_node.script_name, selected_shop_scripts_space, true, true)
					selected_shop_scripts_num += 1
					update_shop_scripts_counter()
					check_if_ready()
				script_node.hide()

func script_mouse_entered(script_node: ScriptFile):
	script_node.hover()
	set_tooltip(script_node)

func script_mouse_exited(script_node: ScriptFile):
	script_node.dehover()
	reset_tooltip()

func update_scripts_counter():
	var colour
	if selected_scripts_num < max_scripts_num:
		colour = ColourPalette.red
	else:
		colour = ColourPalette.green
	scripts_counter.text = "[color=" + colour + "]" + str(selected_scripts_num) + "/" + str(max_scripts_num) + "[/color]"

func update_shop_scripts_counter():
	var colour
	if selected_shop_scripts_num < max_shop_scripts_num:
		colour = ColourPalette.red
	else:
		colour = ColourPalette.green
	shop_scripts_counter.text = "[color=" + colour + "]" + str(selected_shop_scripts_num) + "/" + str(max_shop_scripts_num) + "[/color]"

func check_if_ready():
	if name_entered and selected_scripts_num == max_scripts_num and selected_shop_scripts_num == max_shop_scripts_num:
		ready_button.disabled = false
	else:
		ready_button.disabled = true

func set_tooltip(script: ScriptFile):
	hide_tooltip_timer.stop()
	if current_tooltip and script.tooltip != current_tooltip:
		current_tooltip.make_transparent()
		current_tooltip = script.tooltip
		current_tooltip.update_position()
		current_tooltip.make_opaque()
	else:
		next_tooltip = script.tooltip
		show_tooltip_timer.start()

func reset_tooltip():
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

func _on_text_edit_text_changed(new_text: String):
	if new_text.length() > 0:
		name_entered = true
	else:
		name_entered = false
	check_if_ready()
