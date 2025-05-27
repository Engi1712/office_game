extends Node2D

@export var skin_colour: String
@export var lips_colour: String
@export var eyes_colour: String
@export var brows_colour: String
@export var hair_style: String
@export var hair_colour: String
@export var beard_style: String
@export var beard_colour: String
@export var shoes: String
@export var trousers: String
@export var shirt: String
@export var jacket: String

@onready var shadow = $Shadow
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
	update_beard()

func update_clothes():
	update_shoes()
	update_trousers()
	update_shirt()
	update_jacket()

func update_skin():
	for i in $Body/Skin.get_children():
		if i.get_name() == skin_colour:
			i.visible = true
		else:
			i.visible = false

func update_lips():
	for i in $Body/Lips.get_children():
		if i.get_name() == lips_colour:
			i.visible = true
		else:
			i.visible = false

func update_eyes():
	for i in $Body/Eyes.get_children():
		if i.get_name() == eyes_colour:
			i.visible = true
		else:
			i.visible = false

func update_brows():
	for i in $Body/Brows.get_children():
		if i.get_name() == brows_colour:
			i.visible = true
		else:
			i.visible = false

func update_hair():
	for i in $Body/Hair.get_children():
		if i.get_name() == hair_style:
			i.visible = true
			for j in i.get_children():
				if j.get_name() == hair_colour:
					j.visible = true
				else:
					j.visible = false
		else:
			i.visible = false
	for i in $Body2/Hair.get_children():
		if i.get_name() == hair_style:
			i.visible = true
			for j in i.get_children():
				if j.get_name() == hair_colour:
					j.visible = true
				else:
					j.visible = false
		else:
			i.visible = false

func update_beard():
	for i in $Body/Beard.get_children():
		if i.get_name() == beard_style:
			i.visible = true
			for j in i.get_children():
				if j.get_name() == beard_colour:
					j.visible = true
				else:
					j.visible = false
		else:
			i.visible = false
	for i in $Body2/Beard.get_children():
		if i.get_name() == beard_style:
			i.visible = true
			for j in i.get_children():
				if j.get_name() == beard_colour:
					j.visible = true
				else:
					j.visible = false
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

func update_jacket():
	for i in $Clothes/Jacket.get_children():
		if i.get_name() == jacket:
			i.visible = true
		else:
			i.visible = false

func disable_shadow():
	shadow.visible = false

func enable_shadow():
	shadow.visible = true
