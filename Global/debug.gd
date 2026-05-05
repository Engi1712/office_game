class_name DebugOptions

enum parts {
	MAIN,
	BATTLE
}

enum battle_jump_in {
	HOT_SEAT,
	BOT,
	NONE
}

var cur_part: parts
var battle_jump_in_place: battle_jump_in

func _init():
	cur_part = parts.MAIN
	battle_jump_in_place = battle_jump_in.NONE
