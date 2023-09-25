extends Node2D

signal clock_tick(clock_time)
signal calendar_update(day)
var clock_time : int = 0
var day : int = 24

func _ready():
	connect("clock_tick", $UI/Status, "update_clock")
	connect("calendar_update", $UI/Status, "update_date")
	connect("clock_tick", $UI/Measures, "update_measures")
	$UI/Status/Advance.connect("pressed", self, "advance_day")
	move_passage_of_time()

func move_passage_of_time():
	$PassageOfTime.start()
	yield($PassageOfTime, "timeout")
	tick()

func roll_over_clock():
	clock_time = 0
	day += 1
	emit_signal("calendar_update", day)

func tick():
	clock_time += 1
	if clock_time == (60*60*24):
		roll_over_clock()
	emit_signal("clock_tick", clock_time)
	move_passage_of_time()

func advance_day():
	$PassageOfTime.stop()
	var step = int(((60*60*24)-clock_time) / 60)
	for _i in range(clock_time, 60*60*24, step):
		clock_time += step
		emit_signal("clock_tick", clock_time)
		yield(get_tree(), "idle_frame")

	roll_over_clock()

	emit_signal("clock_tick", clock_time)
	move_passage_of_time()