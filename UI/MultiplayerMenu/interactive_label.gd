class_name InteractiveLabel extends Control

@onready var hover_bg = $HoverBG
@onready var select_bg = $SelectBG
@onready var label = $RichTextLabel

var steam_id: int
var label_text: String

func setup(text: String, text_colour: String, p_steam_id: int):
	label_text = "[color=" + text_colour + "]" + text + "[/color]"
	steam_id = p_steam_id

func _ready():
	label.text = label_text

func hover():
	hover_bg.visible = true

func dehover():
	hover_bg.visible = false

func select():
	select_bg.visible = true

func deselect():
	select_bg.visible = false
