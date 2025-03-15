extends CharacterBody2D

class_name Player

@export var move_speed : float = 80
@export var cam_ready = false

@onready var character_sprite = $CharacterSprite

@onready var all_interactions = []

@onready var all_zones = []

func _ready():
	NavigationManager.on_triggered_player_spawn.connect(_on_spawn)
	if all_interactions:
		enter_interaction(all_interactions[0])
	if all_zones:
		enter_zone(all_zones[0])

func _on_spawn(spawn_position: Vector2, direction: String):
	global_position = spawn_position
	match direction:
		"up":
			character_sprite.update_animation("Idle", Vector2(0, -1))
		"down":
			character_sprite.update_animation("Idle", Vector2(0, 1))
		"right":
			character_sprite.update_animation("Idle", Vector2(1, 0))
		"left":
			character_sprite.update_animation("Idle", Vector2(-1, 0))
	cam_ready = true
	UI.minimap.set_map(global_position)

func _physics_process(_delta):
	var input_direction = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	).normalized()
	
	velocity = input_direction * move_speed
	
	move_and_slide()
	
	if (velocity != Vector2.ZERO):
		character_sprite.update_animation("Walk", input_direction)
		UI.minimap.move_map(global_position)
	else:
		character_sprite.update_animation("Idle", input_direction)
	
	if Input.is_action_just_pressed("interact") and all_interactions:
		execute_interaction(all_interactions[0])
	if Input.is_action_just_released("interact") and all_interactions:
		de_execute_interaction(all_interactions[0])
	if Input.is_action_just_released("debug"):
		character_sprite.skin = ["White", "Black", "Asian", "Arab", "Latina"].pick_random()
		character_sprite.hair = ["BlondeBob", "BrownBob", "GingerBob", "BlackBob", "GreyBob", "WhiteBob"].pick_random()
		character_sprite.brows = ["Blonde", "Brown", "Ginger", "Black", "Grey", "White"].pick_random()
		character_sprite.eyes = ["Blue", "Brown", "Red", "Green", "Grey"].pick_random()
		character_sprite.lips = ["Pink", "Brown", "Red"].pick_random()
		character_sprite.shoes = ["Black", "Brown", "Burgundy"].pick_random()
		character_sprite.trousers = ["Black", "Cream", "Navy"].pick_random()
		character_sprite.shirt = ["White", "Cream", "Black", "Blue"].pick_random()
		character_sprite.update_sprite()

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
