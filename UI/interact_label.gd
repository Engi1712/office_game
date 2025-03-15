extends Control

@onready var label_text = $Panel/Margins/LabelText

func _ready():
	label_text.bbcode_text = "Open"
