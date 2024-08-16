extends Control

var btn_name = [ [ "9", "7", "5", "3", "1", "-1", "-2", "Open", "Alarm" ],
					[ "10", "8", "6", "4", "2", "0", "-3", "Close" ] ]
var cur_btn_i = 1
var cur_btn_j = 7
var elevator_id = 0

func _ready():
	for i in btn_name.size():
		for j in btn_name[i].size():
			get_node("ButtonSelect/B" + btn_name[i][j]).visible = false
			get_node("ButtonLight/B" + btn_name[i][j]).visible = false
	hide()

func activate(id):
	get_tree().paused = true
	elevator_id = id
	get_node("ButtonSelect/B" + btn_name[cur_btn_i][cur_btn_j]).visible = true
	show()

func deactivate():
	hide()
	get_tree().paused = false

func _input(event : InputEvent):
	if event.is_action_pressed("right"):
		if (cur_btn_i + 1 < btn_name.size()) and (cur_btn_j < btn_name[cur_btn_i + 1].size()):
			get_node("ButtonSelect/B" + btn_name[cur_btn_i][cur_btn_j]).visible = false
			cur_btn_i += 1
			get_node("ButtonSelect/B" + btn_name[cur_btn_i][cur_btn_j]).visible = true
	elif event.is_action_pressed("left"):
		if (cur_btn_i - 1 >= 0) and (cur_btn_j < btn_name[cur_btn_i - 1].size()):
			get_node("ButtonSelect/B" + btn_name[cur_btn_i][cur_btn_j]).visible = false
			cur_btn_i -= 1
			get_node("ButtonSelect/B" + btn_name[cur_btn_i][cur_btn_j]).visible = true
	elif event.is_action_pressed("down"):
		if cur_btn_j + 1 < btn_name[cur_btn_i].size():
			get_node("ButtonSelect/B" + btn_name[cur_btn_i][cur_btn_j]).visible = false
			cur_btn_j += 1
			get_node("ButtonSelect/B" + btn_name[cur_btn_i][cur_btn_j]).visible = true
		elif (cur_btn_i - 1 >= 0) and (cur_btn_j + 1 < btn_name[cur_btn_i -1].size()):
			get_node("ButtonSelect/B" + btn_name[cur_btn_i][cur_btn_j]).visible = false
			cur_btn_i -= 1
			cur_btn_j += 1
			get_node("ButtonSelect/B" + btn_name[cur_btn_i][cur_btn_j]).visible = true
	elif event.is_action_pressed("up"):
		if cur_btn_j - 1 >= 0:
			get_node("ButtonSelect/B" + btn_name[cur_btn_i][cur_btn_j]).visible = false
			cur_btn_j -= 1
			get_node("ButtonSelect/B" + btn_name[cur_btn_i][cur_btn_j]).visible = true
	elif event.is_action_pressed("interact"):
		get_node("ButtonLight/B" + btn_name[cur_btn_i][cur_btn_j]).visible = true
		if cur_btn_j < 7:
			ElevatorManager.deliver_elevator(elevator_id, int(btn_name[cur_btn_i][cur_btn_j]))
