class_name JobButton

extends CheckBox

signal job_started(job)
signal job_ready(job)

var job : Habitat.Job
var cooldown_left = 0

func _ready():
	connect('pressed', self, 'job_started')

func job_started():
	release_focus()
	self.disabled = true
	# Maybe want this to happen after the game finishes?
	cooldown_left = job.cooldown
	emit_signal('job_started', job)

func cooldown_tick(_time, step):
	if cooldown_left > 0:
		cooldown_left -= step
		if cooldown_left <= 0:
			cooldown_left = 0
			self.disabled = false
			self.pressed = false
			emit_signal('job_ready', job)
