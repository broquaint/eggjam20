# class_name Habitat
extends Node

const ENERGY_USAGE = 60*60*24*1
const TERRARIUM_DETERIORATION = 60*60*24*1
const LIFE_SYSTEMS_WEAR = 60*60*24*1
# happiness should be based on other factors not arbitrarily worn down
# ditto efficiency
# shield usage should be lumpy

var energy : float = 100.0
var terrarium : float = 100.0
var life_systems : float = 100.0
var shields : float = 100.0
var happiness : float = 100.0
var efficiency : float = 100.0

var jobs = [
	Job.create(
		'Move waste to reactor',
		'energy',
		123456,
		'Tuesday'
	),
	Job.create(
		'Rotate hydroponics',
		'terrarium',
		112233,
		'Wednesday'
	)
]

func update_measures(clock_time: int):
	energy -= float(clock_time) / float(ENERGY_USAGE)
	terrarium -= float(clock_time) / float(TERRARIUM_DETERIORATION)
	life_systems -= float(clock_time) / float(LIFE_SYSTEMS_WEAR)

func job_completed(job):
	pass

class Job:
	var description : String
	var measure_of : String # TODO Maybe make this an enum.
	var cooldown : int
	var scheduled_day : String # TODO Maybe enum this too.
#	var change_effect : Callable

	static func create(d,m,c,s):
		var job = Job.new()
		job.description = d
		job.measure_of = m
		job.cooldown = c
		job.scheduled_day = s
#		job.change_effect = f
		return job
