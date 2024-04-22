extends CharacterBody2D

class_name Player

@export var move_speed : float = 100
@export var starting_direction : Vector2 = Vector2(0, 1)

@onready var animation_tree = $AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")

@onready var all_interactions = []
@onready var interact_label = $"InteractionComponents/InteractLabel"

func _ready():
	NavigationManager.on_triggered_player_spawn.connect(_on_spawn)
	update_animation_parameters(starting_direction)
	update_interactions()
	#position = Vector2(100, 100)

func _on_spawn(spawn_position : Vector2, direction : String):
	global_position = spawn_position
	match direction:
		"up" :
			animation_tree.set("parameters/Walk/blend_position", Vector2(0, -1))
		"down" :
			animation_tree.set("parameters/Walk/blend_position", Vector2(0, 1))
		"right" :
			animation_tree.set("parameters/Walk/blend_position", Vector2(1, 0))
		"left" :
			animation_tree.set("parameters/Walk/blend_position", Vector2(-1, 0))

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
	update_interactions()

func _on_interaction_area_area_exited(area):
	if area.interact_active:
		leave_interaction(area)
	all_interactions.erase(area)
	update_interactions()

func update_interactions():
	if all_interactions:
		interact_label.text = all_interactions[0].interact_label
	else:
		interact_label.text = ""

func execute_interaction(cur_interaction):
	match cur_interaction.interact_type:
		"print" :
			print(cur_interaction.interact_value)
		"cooler" :
			cur_interaction.fill()
		"drawer" :
			cur_interaction.touch()
		"locker" :
			cur_interaction.touch()

func de_execute_interaction(cur_interaction):
	match cur_interaction.interact_type:
		"print" :
			print(cur_interaction.interact_value)
		"cooler" :
			cur_interaction.stop()
		"drawer" :
			pass
		"locker" :
			pass

func leave_interaction(cur_interaction):
	match cur_interaction.interact_type:
		"print" :
			print(cur_interaction.interact_value)
		"cooler" :
			cur_interaction.stop()
		"drawer" :
			cur_interaction.touch()
		"locker" :
			cur_interaction.touch()
