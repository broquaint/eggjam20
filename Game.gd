extends Node2D

signal clock_tick(clock_time)
var clock_time : int = 0

func _ready():
	connect("clock_tick", $UI/Status, "update_clock")
	move_passage_of_time()

func move_passage_of_time():
	$PassageOfTime.start()
	yield($PassageOfTime, "timeout")
	tick()
	
func tick():
	clock_time += 1
	if clock_time == (60*60*24):
		clock_time = 0
	emit_signal("clock_tick", clock_time)
	move_passage_of_time()
