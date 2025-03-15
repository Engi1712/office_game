extends CharacterBody2D

@onready var character_sprite = $CharacterSprite

func _ready():
	character_sprite.body_type = "Female1"
	character_sprite.skin = ["White", "Black", "Asian", "Arab", "Latina"].pick_random()
	character_sprite.hair = ["BlondeBob", "BrownBob", "GingerBob", "BlackBob", "GreyBob", "WhiteBob"].pick_random()
	character_sprite.brows = ["Blonde", "Brown", "Ginger", "Black", "Grey", "White"].pick_random()
	character_sprite.eyes = ["Blue", "Brown", "Red", "Green", "Grey"].pick_random()
	character_sprite.lips = ["Pink", "Brown", "Red"].pick_random()
	character_sprite.shoes = ["Black", "Brown", "Burgundy"].pick_random()
	character_sprite.trousers = ["Black", "Cream", "Navy"].pick_random()
	character_sprite.shirt = ["White", "Cream", "Black", "Blue"].pick_random()
	character_sprite.update_sprite()
	character_sprite.update_animation("Idle", Vector2(-1, 0))
