class_name BattleField extends Control

signal end_turn_button_pressed

@onready var lower_bounty_label = $MarginContainer/VBoxContainer/Middle/Bounty/LowerBounty
@onready var upper_bounty_label = $MarginContainer/VBoxContainer/Middle/Bounty/UpperBounty
@onready var lower_system = $MarginContainer/VBoxContainer/Lower
@onready var upper_system = $MarginContainer/VBoxContainer/Upper

func prepare_lower(player: PlayerSpecs, system_model: SystemCore):
	lower_system.prepare(player, lower_bounty_label, false)
	lower_system.model = system_model
	system_model.view = lower_system
	return lower_system

func prepare_upper(player: PlayerSpecs, system_model: SystemCore):
	upper_system.prepare(player, upper_bounty_label, true)
	upper_system.model = system_model
	system_model.view = upper_system
	return upper_system

func pause():
	mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_DISABLED
	lower_system.pause()
	upper_system.pause()

func resume():
	mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_INHERITED
	lower_system.resume()
	upper_system.resume()

func _on_end_turn_pressed():
	end_turn_button_pressed.emit()
