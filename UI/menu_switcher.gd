extends Node

const main_menu = preload("res://UI/MainMenu/main_menu.tscn")
const player_preparation = preload("res://UI/BattlePreparation/player_preparation.tscn")
const multiplayer_menu = preload("res://UI/MultiplayerMenu/multiplayer_menu.tscn")
const battle_manager = preload("res://Battle/View/battle_manager.tscn")

var params = null

func switch(menu_tag: String, p_params = null):
	var menu_to_load
	
	match menu_tag:
		"main_menu":
			menu_to_load = main_menu
		"player_preparation":
			menu_to_load = player_preparation
		"multiplayer_menu":
			menu_to_load = multiplayer_menu
		"battle":
			menu_to_load = battle_manager
	
	if menu_to_load:
		params = p_params
		get_tree().change_scene_to_packed(menu_to_load)

func get_param(param_name):
	if params != null and params.has(param_name):
		return params[param_name]
	return null
