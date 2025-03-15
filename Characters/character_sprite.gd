extends Node2D

@export var body_type: String
@export var skin: String
@export var hair: String
@export var brows: String
@export var eyes: String
@export var lips: String
@export var shoes: String
@export var trousers: String
@export var shirt: String

func _ready():
	update_sprite()

func update_sprite():
	update_body_type()
	if body_type:
		get_node(body_type).skin = skin
		get_node(body_type).hair = hair
		get_node(body_type).brows = brows
		get_node(body_type).eyes = eyes
		get_node(body_type).lips = lips
		get_node(body_type).shoes = shoes
		get_node(body_type).trousers = trousers
		get_node(body_type).shirt = shirt
		get_node(body_type).update_sprite()

func update_animation(state: String, move_input: Vector2):
	get_node(body_type).update_animation(state, move_input)

func update_body_type():
	for i in get_children():
		if i.get_name() == body_type:
			i.visible = true
		else:
			i.visible = false
