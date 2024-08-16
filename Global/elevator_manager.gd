extends Node

enum elevator_state {CALL, LOAD, CLOSE, WAIT, DELIVER, UNLOAD, FREE}

class Elevator :
	var floor_id : int
	var state : int
	var dst : Array
	var next : int
	var time : int
	
	func _init():
		floor_id = 0
		state = elevator_state.FREE
		dst = []
		next = 0
		time = Time.get_ticks_msec()

var elevators = []
var elevator_num = 2
var call_queue = []
var max_floor = 10
var min_floor = -2
var mutex : Mutex
var rng : RandomNumberGenerator
var floor_time = 1500
var load_time = 5000
var wait_time = 10000

signal on_elevator_open
signal on_elevator_floor
signal on_elevator_close

func _ready():
	for i in range(0, elevator_num):
		elevators.append(Elevator.new())
	mutex = Mutex.new()
	rng = RandomNumberGenerator.new()

func get_closest_down(elevator):
	var closest = min_floor - 1
	for j in elevator.dst.size():
		if elevator.dst[j] > closest and elevator.dst[j] < elevator.floor_id:
			closest = elevator.dst[j]
	return closest

func get_closest_up(elevator):
	var closest = max_floor + 1
	for j in elevator.dst.size():
		if elevator.dst[j] < closest and elevator.dst[j] > elevator.floor_id:
			closest = elevator.dst[j]
	return closest

func _process(_delta):
	mutex.lock()
	var cur_time = Time.get_ticks_msec()
	for i in elevators.size():
		if elevators[i].state == elevator_state.FREE:
			if elevators[i].dst.size():
				if elevators[i].floor_id - min_floor <= max_floor - elevators[i].floor_id:
					var closest = get_closest_down(elevators[i])
					if closest == min_floor - 1:
						closest = get_closest_up(elevators[i])
					elevators[i].next = closest
					elevators[i].time = cur_time
					elevators[i].state = elevator_state.DELIVER
				else:
					var closest = get_closest_up(elevators[i])
					if closest == min_floor - 1:
						closest = get_closest_down(elevators[i])
					elevators[i].next = closest
					elevators[i].time = cur_time
					elevators[i].state = elevator_state.DELIVER
			elif call_queue.size():
				var closest = true
				for j in elevators.size():
					if (elevators[j].state == elevator_state.FREE
							and i != j
							and absi(elevators[j].floor_id - call_queue[0])
							< absi(elevators[i].floor_id - call_queue[0])):
						closest = false
				if closest:
					elevators[i].next = call_queue[0]
					elevators[i].time = cur_time
					elevators[i].state = elevator_state.CALL
					call_queue.remove_at(0)
		elif elevators[i].state == elevator_state.CALL:
			if cur_time - elevators[i].time >= floor_time:
				if elevators[i].next > elevators[i].floor_id:
					elevators[i].floor_id += 1
					on_elevator_floor.emit(i, elevators[i].floor_id)
				elif elevators[i].next < elevators[i].floor_id:
					elevators[i].floor_id -= 1
					on_elevator_floor.emit(i, elevators[i].floor_id)
				elevators[i].time = cur_time
				if elevators[i].next == elevators[i].floor_id:
					elevators[i].state = elevator_state.LOAD
					on_elevator_open.emit(i)
		elif elevators[i].state == elevator_state.LOAD:
			if cur_time - elevators[i].time >= load_time:
				elevators[i].state = elevator_state.CLOSE
				on_elevator_close.emit(i)
		elif elevators[i].state == elevator_state.WAIT:
			if elevators[i].dst.size():
				if elevators[i].floor_id - min_floor <= max_floor - elevators[i].floor_id:
					var closest = get_closest_down(elevators[i])
					if closest == min_floor - 1:
						closest = get_closest_up(elevators[i])
					elevators[i].next = closest
					elevators[i].time = cur_time
					elevators[i].state = elevator_state.DELIVER
				else:
					var closest = get_closest_up(elevators[i])
					if closest == min_floor - 1:
						closest = get_closest_down(elevators[i])
					elevators[i].next = closest
					elevators[i].time = cur_time
					elevators[i].state = elevator_state.DELIVER
			elif cur_time - elevators[i].time >= wait_time:
				elevators[i].state = elevator_state.FREE
		elif elevators[i].state == elevator_state.DELIVER:
			if cur_time - elevators[i].time >= floor_time:
				if elevators[i].next > elevators[i].floor_id:
					elevators[i].floor_id += 1
					on_elevator_floor.emit(i, elevators[i].floor_id)
				elif elevators[i].next < elevators[i].floor_id:
					elevators[i].floor_id -= 1
					on_elevator_floor.emit(i, elevators[i].floor_id)
				elevators[i].time = cur_time
				for j in elevators[i].dst.size():
					if elevators[i].dst[j] == elevators[i].floor_id:
						elevators[i].state = elevator_state.LOAD
						elevators[i].dst.remove_at(j)
						on_elevator_open.emit(i)
	mutex.unlock()

func call_elevator(floor_id):
	mutex.lock()
	for i in elevators.size():
		if ((elevators[i].state == elevator_state.LOAD
				or elevators[i].state == elevator_state.CLOSE
				or elevators[i].state == elevator_state.WAIT
				or elevators[i].state == elevator_state.FREE)
				and elevators[i].floor_id == floor_id):
			elevators[i].state = elevator_state.LOAD
			elevators[i].time = Time.get_ticks_msec()
			mutex.unlock()
			on_elevator_open.emit(i)
			return
	for i in call_queue.size():
		if call_queue[i] == floor_id:
			mutex.unlock()
			return
	call_queue.append(floor_id)
	mutex.unlock()

func deliver_elevator(id, floor_id):
	mutex.lock()
	if elevators[id].floor_id == floor_id:
		if elevators[id].state == elevator_state.LOAD:
			elevators[id].time = Time.get_ticks_msec()
			mutex.unlock()
			return
		if (elevators[id].state == elevator_state.CLOSE
				or elevators[id].state == elevator_state.WAIT):
			elevators[id].state = elevator_state.LOAD
			elevators[id].time = Time.get_ticks_msec()
			mutex.unlock()
			on_elevator_open.emit(id)
			return
	for i in elevators[id].dst.size():
		if elevators[id].dst[i] == floor_id:
			mutex.unlock()
			return
	elevators[id].dst.append(floor_id)
	mutex.unlock()

func closed_elevator(id, success):
	mutex.lock()
	if success:
		elevators[id].state = elevator_state.WAIT
		elevators[id].time = Time.get_ticks_msec()
	else:
		elevators[id].state = elevator_state.LOAD
		elevators[id].time = Time.get_ticks_msec()
	mutex.unlock()
