class_name BattleCommon

enum modes {
	BOT,
	HOT_SEAT,
	STEAM
}

enum window_types {
	BATTLE,
	SHOP,
	PAUSE,
	GAME_OVER
}

enum tooltip_types {
	CPU,
	SCRIPT,
	TOKEN,
	IFACE
}

enum wallpaper_rarity {
	COMMON,
	RARE,
	EPIC,
	LEGENDARY
}

static func get_line_item_type(item_type: BattleCommonCore.item_types):
	match item_type:
		BattleCommonCore.item_types.CPU:
			return "cpu"
		BattleCommonCore.item_types.IFACE:
			return "iface"
		BattleCommonCore.item_types.DISK_D_SCRIPT:
			return "disk d script"

static func get_line_script_direction(script_direction: BattleCommonCore.script_directions):
	match script_direction:
		BattleCommonCore.script_directions.ATTACK:
			return "attack"
		BattleCommonCore.script_directions.DEFEND:
			return "defend"
		BattleCommonCore.script_directions.NET:
			return "net"

static func get_line_script_type(script_type:BattleCommonCore. script_types):
	match script_type:
		BattleCommonCore.script_types.LOAD:
			return "load"
		BattleCommonCore.script_types.UTILITY:
			return "utility"
		BattleCommonCore.script_types.VM:
			return "vm"
		BattleCommonCore.script_types.ANTIVIRUS:
			return "antivirus"
		BattleCommonCore.script_types.PROTECTOR:
			return "protector"
		BattleCommonCore.script_types.MINER:
			return "miner"
		BattleCommonCore.script_types.KEY:
			return "key"
		BattleCommonCore.script_types.TRAFFIC:
			return "traffic"
		BattleCommonCore.script_types.BREAKER:
			return "breaker"
		BattleCommonCore.script_types.CLEANER:
			return "cleaner"
		BattleCommonCore.script_types.BOOSTER:
			return "booster"
		BattleCommonCore.script_types.JAMMER:
			return "jammer"
		BattleCommonCore.script_types.LEGENDARY:
			return "legendary"
