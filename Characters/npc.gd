extends CharacterBody2D

@onready var character_sprite = $CharacterSprite

func _ready():
	character_sprite.body_type = "Male1"
	character_sprite.skin = ["White", "Black", "Asian", "Arab", "Latina"].pick_random()
	character_sprite.hair_style = ["Buzz", "Short", "Balding", "Crop", "Hipster", "Flat-top", "Afro", "Curly", "Curtained", ""].pick_random()
	character_sprite.beard_style = ["Walrus", "Horseshoe", "English", "Full", "Van Dyke", "Anchor", "Circle", "Hollywoodian", "Ducktail", "Sideburns", "Stubble", ""].pick_random()
	if character_sprite.skin == "White":
		character_sprite.hair_colour = ["Blonde", "Brown", "Ginger", "Black", "Grey", "White"].pick_random()
		character_sprite.eyes = ["Blue", "Brown", "Red", "Green", "Grey"].pick_random()
		character_sprite.lips = "Pink"
	else:
		character_sprite.hair_colour = ["Black", "Grey"].pick_random()
		character_sprite.eyes = ["Brown", "Red"].pick_random()
		if character_sprite.skin == "Asian":
			character_sprite.lips = "Pink"
		else:
			character_sprite.lips = "Brown"
	character_sprite.jacket = ["Black", "Cream", "Navy"].pick_random()
	character_sprite.trousers = character_sprite.jacket
	if character_sprite.jacket == "Black":
		character_sprite.shirt = ["White", "Cream", "Black", "Blue"].pick_random()
		character_sprite.shoes = "Black"
	elif character_sprite.jacket == "Cream":
		character_sprite.shirt = ["White", "Cream"].pick_random()
		character_sprite.shoes = "Brown"
	elif character_sprite.jacket == "Navy":
		character_sprite.shirt = ["White", "Blue"].pick_random()
		character_sprite.shoes = "Burgundy"
	character_sprite.update_sprite()
	character_sprite.update_animation("Idle", Vector2(0, 1))
