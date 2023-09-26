class_name JobButton

extends CheckBox

signal job_done(job)

var job : Habitat.Job

func _ready():
	connect('pressed', self, 'job_done')

func job_done():
	emit_signal('job_done', job)
