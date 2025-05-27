class_name Player extends CharacterBody2D

@export var move_speed : float = 80
@export var spawned = false

@onready var character_sprite = $CharacterSprite

var all_interactions = []
var all_locations = []

func _ready():
	NavigationManager.on_triggered_player_spawn.connect(_on_spawn)
	if all_interactions:
		all_interactions[0].enter()
	if all_locations:
		all_locations[0].enter()

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
	spawned = true
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
		all_interactions[0].activate()
	if Input.is_action_just_released("interact") and all_interactions:
		all_interactions[0].deactivate()
	if Input.is_action_just_released("debug"):
		random_look()

func random_look():
	var body_res = load("res://GameData/Bodies/" + character_sprite.body + ".tres")
	body_res.sex = "Male"
	body_res.type = "1"
	body_res.skin_colour = ["White", "Black", "Asian", "Arab", "Latina"].pick_random()
	body_res.hair_style = ["Buzz", "Short", "Balding", "Crop", "Hipster", "Flat-top", "Afro", "Curly", "Curtained", ""].pick_random()
	body_res.beard_style = ["Walrus", "Horseshoe", "English", "Full", "Van Dyke", "Anchor", "Circle", "Hollywoodian", "Ducktail", "Sideburns", "Stubble", ""].pick_random()
	if body_res.skin_colour == "White":
		body_res.hair_colour = ["Blonde", "Brown", "Ginger", "Black", "Grey", "White"].pick_random()
		body_res.eyes_colour = ["Blue", "Brown", "Red", "Green", "Grey"].pick_random()
		body_res.lips_colour = "Pink"
	else:
		body_res.hair_colour = ["Black", "Grey"].pick_random()
		body_res.eyes_colour = ["Brown", "Red"].pick_random()
		if body_res.skin_colour == "Asian":
			body_res.lips_colour = "Pink"
		else:
			body_res.lips_colour = "Brown"
	body_res.beard_colour = body_res.hair_colour
	ResourceSaver.save(body_res)
	character_sprite.update_body()
	UI.update_character()

#Areas

func _on_interaction_area_area_entered(area):
	all_interactions.insert(0, area)
	area.enter()

func _on_interaction_area_area_exited(area):
	all_interactions.erase(area)
	area.exit()

func _on_location_area_area_entered(area):
	all_locations.insert(0, area)
	area.enter()
	if area.location_type == "draw":
		z_index = -9

func _on_location_area_area_exited(area):
	all_locations.erase(area)
	area.exit()
	if area.location_type == "draw":
		z_index = 0
