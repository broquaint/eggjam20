class_name JobButton

extends CheckBox

signal job_started(job)

var job : Habitat.Job

func _ready():
	connect('pressed', self, 'job_started')

func job_started():
	release_focus()
	emit_signal('job_started', job)
