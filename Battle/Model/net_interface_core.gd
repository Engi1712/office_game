class_name NetInterfaceCore extends ItemCore

var id: int
var iface_name: String

var min_traffic: int = 0
var max_traffic: int = 100
var cur_traffic: int

func _init(p_id: int):
	id = p_id
	item_type = BattleCommonCore.item_types.IFACE
	cur_traffic = min_traffic

func add_traffic(delta: int):
	cur_traffic += delta

func reset_traffic():
	cur_traffic = 0

func get_resulting_traffic(new_traffic: int):
	if cur_traffic + new_traffic < min_traffic:
		new_traffic = cur_traffic - min_traffic
	elif cur_traffic + new_traffic > max_traffic:
		new_traffic = max_traffic - cur_traffic
	return new_traffic
