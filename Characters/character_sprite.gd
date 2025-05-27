extends Node2D

@export var body: String
@export var inventory: String

var body_type: String = ""

func _ready():
	update_sprite()
	UI.on_inv_changed.connect(_on_inv_updated)

func update_sprite():
	update_body()
	update_clothes()

func update_body():
	var body_res: Body = load("res://GameData/Bodies/" + body + ".tres")
	body_type = ""
	for i in get_children():
		if i.get_name() == body_res.sex + body_res.type:
			i.visible = true
			body_type = i.get_name()
		else:
			i.visible = false
	if body_type == "":
		return
	var sprite := get_node(body_type)
	sprite.skin_colour = body_res.skin_colour
	sprite.lips_colour = body_res.lips_colour
	sprite.eyes_colour = body_res.eyes_colour
	sprite.brows_colour = body_res.brows_colour
	sprite.hair_style = body_res.hair_style
	sprite.hair_colour = body_res.hair_colour
	sprite.beard_style = body_res.beard_style
	sprite.beard_colour = body_res.beard_colour
	sprite.update_body()

func update_clothes():
	var inv_res: InvChar = load("res://GameData/Inventories/" + inventory + ".tres")
	if body_type == "":
		return
	var sprite := get_node(body_type)
	if inv_res.shoes_slot.item:
		sprite.shoes = inv_res.shoes_slot.item.id.get_slice("_", 0).capitalize()
	else:
		sprite.shoes = ""
	if inv_res.trousers_slot.item:
		sprite.trousers = inv_res.trousers_slot.item.id.get_slice("_", 0).capitalize()
	else:
		sprite.trousers = ""
	if inv_res.shirt_slot.item:
		sprite.shirt = inv_res.shirt_slot.item.id.get_slice("_", 0).capitalize()
	else:
		sprite.shirt = ""
	if inv_res.jacket_slot.item:
		sprite.jacket = inv_res.jacket_slot.item.id.get_slice("_", 0).capitalize()
	else:
		sprite.jacket = ""
	sprite.update_clothes()

func update_animation(state: String, move_input: Vector2):
	if body_type == "":
		return
	get_node(body_type).update_animation(state, move_input)

func _on_inv_updated(res_name: String):
	if res_name != inventory:
		return
	update_clothes()

func disable_shadow():
	if body_type == "":
		return
	get_node(body_type).disable_shadow()

func enable_shadow():
	if body_type == "":
		return
	get_node(body_type).enable_shadow()
