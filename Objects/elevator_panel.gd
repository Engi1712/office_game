extends Node2D

func touch():
	get_parent()._on_elevator_panel_activate()

func release():
	pass

func approach():
	pass

func leave():
	pass
