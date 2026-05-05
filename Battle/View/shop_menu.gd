class_name ShopMenu extends Control

signal buy_button_pressed

@onready var lower_shop = $PanelContainer/MarginContainer/VBoxContainer/Lower
@onready var upper_shop = $PanelContainer/MarginContainer/VBoxContainer/Upper
@onready var buy_button = $PanelContainer/MarginContainer/VBoxContainer/Buy

var opened: bool

func _ready():
	close()

func prepare_lower(shop_model: ShopCore):
	lower_shop.prepare(buy_button)
	lower_shop.model = shop_model
	shop_model.view = lower_shop
	return lower_shop

func prepare_upper(shop_model: ShopCore):
	upper_shop.prepare(buy_button)
	upper_shop.model = shop_model
	shop_model.view = upper_shop
	return upper_shop

func open():
	opened = true
	show()

func close():
	opened = false
	hide()

func is_opened():
	return opened

func _on_buy_pressed():
	buy_button_pressed.emit()
