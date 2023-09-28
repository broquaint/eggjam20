# class_name Habitat
extends Node

signal measures_updated()

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

onready var feed_reactor_scene = preload("res://scenes/FeedReactor.tscn")
onready var maintain_hydroponics_scene = preload("res://scenes/MaintainHydroponics.tscn")

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
		'Maintain hydroponics',
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

func job_begun(job):
	job.change_effect.call_func()
	emit_signal("measures_updated")

func _job_feed_reactor():
	var feed_reactor = feed_reactor_scene.instance()
	feed_reactor.position = Vector2(112, 84)
	get_node("/root/Root").add_child(feed_reactor)
	var res = yield(feed_reactor, "game_completed")

	yield(get_tree().create_timer(2.0), 'timeout')
	var fade = get_tree().create_tween()
	fade.tween_property(feed_reactor, 'modulate', Color('#00ffffff'), 1.0)
	fade.tween_callback(feed_reactor, 'queue_free')

	var up_by = float(ENERGY_USAGE) * (float(res[1]) / float(res[0]))
	var new_val = clamp(energy + up_by, 0.0, float(ENERGY_MAX))
	print("energy from ", energy, ' to ', new_val, ' based on ', res, ' up by ', up_by)
	energy = new_val

func _job_rotate_hydroponics():
	var maintain_hydroponics = maintain_hydroponics_scene.instance()
	maintain_hydroponics.position = Vector2(112, 84)
	get_node("/root/Root").add_child(maintain_hydroponics)
	var score = yield(maintain_hydroponics, "game_completed")

	yield(get_tree().create_timer(1.0), 'timeout')
	var fade = get_tree().create_tween()
	fade.tween_property(maintain_hydroponics, 'modulate', Color('#00ffffff'), 1.0)
	fade.tween_callback(maintain_hydroponics, 'queue_free')

	var up_by = float(TERRARIUM_DETERIORATION) * (1 + (score/10))
	var new_val = clamp(terrarium + up_by, 0.0, float(TERRARIUM_MAX))
	print("terrarium from ", terrarium, ' to ', new_val, ' based on ', score, ' up by ', up_by)
	terrarium = new_val

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
