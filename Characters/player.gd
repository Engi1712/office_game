extends CharacterBody2D

class_name Player

@export var move_speed : float = 80
@export var starting_direction : Vector2 = Vector2(0, 1)
@export var cam_ready = false

@onready var animation_tree = $AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")

@onready var all_interactions = []
@onready var interact_label = $"InteractionComponents/InteractLabel"

@onready var all_zones = []

func _ready():
	NavigationManager.on_triggered_player_spawn.connect(_on_spawn)
	update_animation_parameters(starting_direction)
	if all_interactions:
		enter_interaction(all_interactions[0])
	if all_zones:
		enter_zone(all_zones[0])
	#position = Vector2(100, 100)

func _on_spawn(spawn_position : Vector2, direction : String):
	global_position = spawn_position
	match direction:
		"up" :
			animation_tree.set("parameters/Walk/blend_position", Vector2(0, -1))
			animation_tree.set("parameters/Idle/blend_position", Vector2(0, -1))
		"down" :
			animation_tree.set("parameters/Walk/blend_position", Vector2(0, 1))
			animation_tree.set("parameters/Idle/blend_position", Vector2(0, 1))
		"right" :
			animation_tree.set("parameters/Walk/blend_position", Vector2(1, 0))
			animation_tree.set("parameters/Idle/blend_position", Vector2(1, 0))
		"left" :
			animation_tree.set("parameters/Walk/blend_position", Vector2(-1, 0))
			animation_tree.set("parameters/Idle/blend_position", Vector2(-1, 0))
	cam_ready = true

func _physics_process(_delta):
	var input_direction = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	).normalized()
	
	update_animation_parameters(input_direction)
	
	velocity = input_direction * move_speed
	
	move_and_slide()
	
	pick_new_state()
	
	if Input.is_action_just_pressed("interact") and all_interactions:
		execute_interaction(all_interactions[0])
	if Input.is_action_just_released("interact") and all_interactions:
		de_execute_interaction(all_interactions[0])

func update_animation_parameters(move_input : Vector2):
	if (move_input != Vector2.ZERO):
		animation_tree.set("parameters/Walk/blend_position", move_input)
		animation_tree.set("parameters/Idle/blend_position", move_input)

func pick_new_state():
	if (velocity != Vector2.ZERO):
		state_machine.travel("Walk")
	else:
		state_machine.travel("Idle")

#Interaction methods

func _on_interaction_area_area_entered(area):
	all_interactions.insert(0, area)
	enter_interaction(area)

func _on_interaction_area_area_exited(area):
	all_interactions.erase(area)
	exit_interaction(area)

func _on_location_area_area_entered(area):
	all_zones.insert(0, area)
	enter_zone(area)

func _on_location_area_area_exited(area):
	all_zones.erase(area)
	exit_zone(area)

func enter_interaction(cur_interaction):
	cur_interaction.enter()

func exit_interaction(cur_interaction):
	cur_interaction.exit()

func enter_zone(cur_zone):
	match cur_zone.zone_type:
		"draw" :
			z_index = -9
		"open" :
			cur_zone.open()

func exit_zone(cur_zone):
	match cur_zone.zone_type:
		"draw" :
			z_index = 0
		"open" :
			cur_zone.close()

func execute_interaction(cur_interaction):
	cur_interaction.activate()

func de_execute_interaction(cur_interaction):
	cur_interaction.deactivate()
