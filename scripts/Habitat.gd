# class_name Habitat
extends Node

const DAY : int  = 60 * 60 * 24
const WEEK : int = DAY * 7

const ENERGY_USAGE = DAY
const TERRARIUM_DETERIORATION = DAY
#const LIFE_SYSTEMS_WEAR = DAY
# happiness should be based on other factors not arbitrarily worn down
# ditto efficiency
# shield usage should be lumpy

const ENERGY_MAX = WEEK
const TERRARIUM_MAX = WEEK * 2
const LIFE_SYSTEMS_MAX = WEEK / 2

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
		'Tuesday',
		funcref(self, '_job_feed_reactor')
	),
	Job.create(
		'Rotate hydroponics',
		'terrarium',
		112233,
		'Wednesday',
		funcref(self, '_job_rotate_hydroponics')
	)
]

func _ready():
	self.energy = ENERGY_MAX
	self.terrarium = TERRARIUM_MAX
#	self.life_systems = LIFE_SYSTEMS_MAX
#	var shields : float = 100.0
#	var happiness : float = 100.0
#	var efficiency : float = 100.0

func update_measures(_time: int, delta: int):
	energy -= float(delta)#  / float(ENERGY_USAGE)
	terrarium -= float(delta)# / float(TERRARIUM_DETERIORATION)
#	print("energy now ", energy, " after ", delta)
#	life_systems -= float(clock_time) / float(LIFE_SYSTEMS_WEAR)

func job_completed(job):
	job.change_effect.call_func()

func _job_feed_reactor():
	energy = clamp(energy + ENERGY_USAGE, 0.0, ENERGY_MAX)

func _job_rotate_hydroponics():
	terrarium = clamp(terrarium + TERRARIUM_DETERIORATION, 0.0, TERRARIUM_MAX)

func energy_percent():
	return 100 * (energy / ENERGY_MAX)

func terrarium_percent():
	return 100 * (terrarium / TERRARIUM_MAX)

class Job:
	var description : String
	var measure_of : String # TODO Maybe make this an enum.
	var cooldown : int
	var scheduled_day : String # TODO Maybe enum this too.
	var change_effect : FuncRef

	static func create(d,m,c,s,f):
		var job = Job.new()
		job.description = d
		job.measure_of = m
		job.cooldown = c
		job.scheduled_day = s
		job.change_effect = f
		return job
