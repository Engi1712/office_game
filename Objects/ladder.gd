extends StaticBody2D

@export var destination_level_tag : String
@export var destination_door_tag : String
@export var spawn_direction : String

@onready var spawn = $Spawn

func transfer():
	NavigationManager.call_deferred("go_to_level", destination_level_tag, destination_door_tag)
