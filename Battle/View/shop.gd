class_name Shop extends VBoxContainer

signal item_added(item: Control)

const template_script_node = preload("res://Battle/View/script_file.tscn")
const template_tooltip = preload("res://Battle/View/tooltip.tscn")

@onready var script_space: VBoxContainer = $Scripts
@onready var balance_label: RichTextLabel = $HBoxContainer/Balance
var buy_button: Button

var model: ShopCore

# --- Public ---

func prepare(p_buy_button: Button):
	buy_button = p_buy_button

func update_full():
	if model.active:
		visible = true
		update_scripts()
		update_selection()
		update_balance()
	else:
		visible = false

func update_selection():
	if !model.active:
		return
	for i in script_space.get_children():
		if i.model == model.cur_script:
			i.select()
			if model.owner_system.check_token(BattleCommonCore.tokens.TAUCOIN, i.shop_price):
				buy_button.disabled = false
			else:
				buy_button.disabled = true
		else:
			i.deselect()

# --- Private ---

func update_scripts():
	for i in model.scripts:
		if !i.view:
			create_script_view(i)
		if model.owner_system.check_token(BattleCommonCore.tokens.TAUCOIN, i.shop_price):
			i.view.can_afford = true
		else:
			i.view.can_afford = false
		i.view.update()

func update_balance():
	balance_label.text = str(model.owner_system.get_token(BattleCommonCore.tokens.TAUCOIN)) + \
			" [img]res://Art/Office Pack/Battle/Icons/Tokens/taucoin.png[/img]"

func create_script_view(script_model: ScriptFileCore):
	var new_view = template_script_node.instantiate()
	new_view.model = script_model
	script_model.view = new_view
	script_space.add_child(new_view)
	add_tooltip(new_view)
	item_added.emit(new_view)

func add_tooltip(parent_node: Control):
	var new_tooltip = template_tooltip.instantiate()
	new_tooltip.upper = true
	new_tooltip.type = BattleCommon.tooltip_types.SCRIPT
	new_tooltip.parent_node = parent_node
	parent_node.tooltip = new_tooltip
	parent_node.add_child(new_tooltip)
