extends Node2D

@export var skin: String
@export var hair: String
@export var brows: String
@export var eyes: String
@export var lips: String
@export var shoes: String
@export var trousers: String
@export var shirt: String

@onready var animation_tree = $AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")

func _ready():
	update_sprite()

func update_sprite():
	update_body()
	update_clothes()

func update_animation(state: String, move_input: Vector2):
	if (move_input != Vector2.ZERO):
		animation_tree.set("parameters/Walk/blend_position", move_input)
		animation_tree.set("parameters/Idle/blend_position", move_input)
	state_machine.travel(state)

func update_body():
	update_skin()
	update_lips()
	update_eyes()
	update_brows()
	update_hair()

func update_clothes():
	update_shoes()
	update_trousers()
	update_shirt()

func update_skin():
	for i in $Body/Skin.get_children():
		if i.get_name() == skin:
			i.visible = true
		else:
			i.visible = false

func update_lips():
	for i in $Body/Lips.get_children():
		if i.get_name() == lips:
			i.visible = true
		else:
			i.visible = false

func update_eyes():
	for i in $Body/Eyes.get_children():
		if i.get_name() == eyes:
			i.visible = true
		else:
			i.visible = false

func update_brows():
	for i in $Body/Brows.get_children():
		if i.get_name() == brows:
			i.visible = true
		else:
			i.visible = false

func update_hair():
	for i in $Body/Hair.get_children():
		if i.get_name() == hair:
			i.visible = true
		else:
			i.visible = false

func update_shoes():
	for i in $Clothes/Shoes.get_children():
		if i.get_name() == shoes:
			i.visible = true
		else:
			i.visible = false

func update_trousers():
	for i in $Clothes/Trousers.get_children():
		if i.get_name() == trousers:
			i.visible = true
		else:
			i.visible = false

func update_shirt():
	for i in $Clothes/Shirt.get_children():
		if i.get_name() == shirt:
			i.visible = true
		else:
			i.visible = false
