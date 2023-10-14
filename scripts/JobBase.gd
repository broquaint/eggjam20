class_name JobBase

extends Node2D

signal job_summary_message(source, message)
signal job_description_message(source, message)

func setup(arguments):
	assert(false, "Looks like %s forgot to implement JobBase.setup(args)!" % str(self))

func job_summary(msg):
	emit_signal('job_summary_message', 'Job summary', msg)

func job_description(msg):
	emit_signal('job_description_message', 'Job description', msg)
