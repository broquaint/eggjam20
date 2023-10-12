# class_name Habitat
extends Node

signal measures_updated()

const CONFIG_PATH = 'user://gamestate.cfg'

const DAY : int  = 60 * 60 * 24
const WEEK : int = DAY * 7

const ENERGY_USAGE = DAY
const TERRARIUM_DETERIORATION = DAY
const LIFE_SYSTEMS_WEAR = DAY
# happiness should be based on other factors not arbitrarily worn down
# ditto efficiency
# shield usage should be lumpy

const ENERGY_MAX = WEEK
const TERRARIUM_MAX = WEEK * 2
const LIFE_SYSTEMS_MAX = WEEK * 1.2

var settings = {}

var feed_reactor_scene = "res://scenes/FeedReactor.tscn"
var check_life_systems_scene = "res://scenes/CheckLifeSystems.tscn"
var maintain_hydroponics_scene = "res://scenes/MaintainHydroponics.tscn"

onready var root = get_node('/root/Root')

# measures
var energy : float = 100.0
var terrarium : float = 100.0
var life_systems : float = 100.0
var shields : float = 100.0
var happiness : float = 100.0
var efficiency : float = 100.0

# resources
var trash_balls : int = 2
var butterflies : int = 10
var critters : int = 5 # On off switches instead?

var intro_seen = false

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
	),
	Job.create(
		'Check life systems ',
		'life_systems',
		123123,
		'Thursday',
		funcref(self, '_job_check_life_systems')
	)
]

func _ready():
	self.energy = ENERGY_MAX
	self.terrarium = TERRARIUM_MAX
	self.life_systems = LIFE_SYSTEMS_MAX
#	var shields : float = 100.0
#	var happiness : float = 100.0
#	var efficiency : float = 100.0

func update_measures(_time: int, delta: int):
	energy -= float(delta)#  / float(ENERGY_USAGE)
	terrarium -= float(delta)# / float(TERRARIUM_DETERIORATION)
	life_systems -= float(delta)
#	print("energy now ", energy, " after ", delta)
#	life_systems -= float(clock_time) / float(LIFE_SYSTEMS_WEAR)

func day_done():
	trash_balls = clamp(trash_balls + 1, 1, 8)
	butterflies = clamp(butterflies + 2, 1, 20)
	critters    = clamp(critters    + 1, 1, 18)

func job_begun(job):
	job.change_effect.call_func()
	emit_signal("measures_updated")

func _job_feed_reactor():
	root.display_job(feed_reactor_scene, { trash_balls = trash_balls })
	var res = yield(root, 'job_finished')

	var up_by = float(ENERGY_USAGE) * (float(res.score) / float(res.total))
	var new_val = clamp(energy + up_by, 0.0, float(ENERGY_MAX))
	print("energy from ", energy, ' to ', new_val, ' based on ', res, ' up by ', up_by)
	energy = new_val
	trash_balls -= res.total

func _job_rotate_hydroponics():
	root.display_job(maintain_hydroponics_scene, { butterflies = butterflies })
	var score = yield(root, 'job_finished')

	var up_by = float(TERRARIUM_DETERIORATION) * (1 + (score/10))
	var new_val = clamp(terrarium + up_by, 0.0, float(TERRARIUM_MAX))
	print("terrarium from ", terrarium, ' to ', new_val, ' based on ', score, ' up by ', up_by)
	terrarium = new_val

	energy -= float(ENERGY_USAGE) / 2
	trash_balls += 1

func _job_check_life_systems():
	root.display_job(check_life_systems_scene, { critters = critters })
	var res = yield(root, 'job_finished')

	var up_by = float(LIFE_SYSTEMS_WEAR) * (res.o2_score + res.h2o_score)
	var new_val = clamp(life_systems + up_by, 0.0, float(LIFE_SYSTEMS_MAX))
	print("life_systems from ", life_systems, ' to ', new_val, ' based on ', res, ' up by ', up_by)
	life_systems = new_val	

	energy -= float(ENERGY_USAGE)
	trash_balls += 1

func energy_percent():
	return 100 * (energy / ENERGY_MAX)

func terrarium_percent():
	return 100 * (terrarium / TERRARIUM_MAX)

func life_systems_percent():
	return 100 * (life_systems / LIFE_SYSTEMS_MAX)

func intro_acknowledged():
	self.intro_seen = true
	save_setting_value('seen_intro', true)

func load_settings():
	var config = ConfigFile.new()
	var res = config.load(CONFIG_PATH)
	if res != OK:
		settings = {
			seen_intro = false,
		}
	else:
		settings.seen_intro   = config.get_value('settings', 'seen_intro', false)

func save_setting_value(k, v):
	var config = ConfigFile.new()
	for sk in settings.keys():
		config.set_value('settings', sk, settings[sk])
	config.set_value('settings', k, v)
	settings[k] = v
	config.save(CONFIG_PATH)

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
