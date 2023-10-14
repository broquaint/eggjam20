extends Node2D

signal clock_tick(clock_time)
signal calendar_update()
signal job_finished(res)
signal daily_message(source, message)

var clock_time : int = 0
var clock_step : int = 1

func _ready():
	randomize()

	Habitat.load_settings()

	connect("clock_tick", $UI/Status, "update_clock")
	connect("calendar_update", $UI/Status, "update_date")
	connect("calendar_update", Habitat, "day_done")
	connect("clock_tick", $UI/Measures, "tick_update_measures")
	connect("clock_tick", Habitat, "update_measures")
	Habitat.connect("measures_updated", $UI/Measures, "change_update_measures")
	$UI/Status/Advance.connect("pressed", self, "advance_day")
	$PassageOfTime.connect('timeout', self, 'tick')

	connect('daily_message', $UI/Messages, 'message_received')
	Habitat.connect('measure_change_message', $UI/Messages, 'message_received')

	for stub in $UI/JobList/Jobs.get_children():
		$UI/JobList/Jobs.remove_child(stub)

	for job in Habitat.jobs:
		var jb = JobButton.new()
		jb.job = job
		jb.text = job.description
		jb.connect('job_started', Habitat, 'job_begun')
		jb.connect('job_started', $UI/JobList, 'job_start')
		jb.connect('job_ready',   $UI/JobList, 'job_end')
		connect('clock_tick', jb, 'cooldown_tick')
		$UI/JobList/Jobs.add_child(jb)

	if not Habitat.settings.seen_intro:
		$UI/IntroMessage.show()

	$UI/IntroMessage.connect('confirmed', Habitat, 'intro_acknowledged')

	$PassageOfTime.start()

	next_daily_message()

func roll_over_clock():
	clock_time = 0
	emit_signal("calendar_update")
	if not day_help_messages.empty():
		next_daily_message()

func next_daily_message():
	emit_signal('daily_message', "Helper", day_help_messages.pop_front())

func tick():
	clock_time += clock_step
	if clock_time >= (60*60*24):
		roll_over_clock()
	emit_signal("clock_tick", clock_time, clock_step)
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

func display_job(job_scene, arguments = {}):
	clock_step = 1800

	var job = JobFactory.make_scene(job_scene, arguments)
	job.position = Vector2(140, 48)
	job.connect('job_summary_message', $UI/Messages, 'message_received')
	job.connect('job_description_message', $UI/Messages, 'message_received')
	add_child(job)
	var res = yield(job, "game_completed")

	yield(get_tree().create_timer(2.0), 'timeout')
	var fade = get_tree().create_tween()
	fade.tween_property(job, 'modulate', Color('#00ffffff'), 1.0)
	fade.tween_callback(job, 'queue_free')
	yield(fade, 'finished')

	emit_signal("job_finished", res)

	clock_step = 1

var day_help_messages = [
	# Monday
	'Welcome to the Maekruea Yao Space Habitat, Director! As today is a Monday and all the systems are running smoothly you have nothing to do today.', # Maybe make games freely playable on Mondays??
	# Tuesday
	'As the first working day of the week you might want to attend to the "Maintain hydroponics" job.',
	# Wednesday
	'The critters in the lifesytems are at it again, why don\'t you "Check lifesystems"?',
	# Thursday
	'This is yet another day …',
	# Friday
	'Last day of the week, hurrah!'
]
