extends Node2D

signal clock_tick(clock_time)
signal calendar_update()
signal job_finished(res)

var clock_time : int = 0

func _ready():
	randomize()

	connect("clock_tick", $UI/Status, "update_clock")
	connect("calendar_update", $UI/Status, "update_date")
	connect("clock_tick", $UI/Measures, "tick_update_measures")
	connect("clock_tick", Habitat, "update_measures")
	Habitat.connect("measures_updated", $UI/Measures, "change_update_measures")
	$UI/Status/Advance.connect("pressed", self, "advance_day")
	$PassageOfTime.connect('timeout', self, 'tick')

	for stub in $UI/JobList/Jobs.get_children():
		$UI/JobList/Jobs.remove_child(stub)
	for job in Habitat.jobs:
		var jb = JobButton.new()
		jb.job = job
		jb.text = job.description
		jb.connect('job_started', Habitat, 'job_begun')
		$UI/JobList/Jobs.add_child(jb)

	$PassageOfTime.start()

func roll_over_clock():
	clock_time = 0
	emit_signal("calendar_update")

func tick():
	clock_time += 1
	if clock_time == (60*60*24):
		roll_over_clock()
	emit_signal("clock_tick", clock_time, 1)
	$PassageOfTime.start()

func advance_day():
	$PassageOfTime.stop()
	var step = ((60*60*24)-clock_time) / 60
	for _i in range(clock_time, 60*60*24, step):
		clock_time += step
		emit_signal("clock_tick", clock_time, step)
		yield(get_tree(), "idle_frame")

	roll_over_clock()

	emit_signal("clock_tick", clock_time, 1)
	$PassageOfTime.start()

func display_job(job_scene):
	# Should really do all this in the actual Root node
	var job = job_scene.instance()
	job.position = Vector2(140, 48)
	add_child(job)
	var res = yield(job, "game_completed")

	yield(get_tree().create_timer(2.0), 'timeout')
	var fade = get_tree().create_tween()
	fade.tween_property(job, 'modulate', Color('#00ffffff'), 1.0)
	fade.tween_callback(job, 'queue_free')

	emit_signal("job_finished", res)
