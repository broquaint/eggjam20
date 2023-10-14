# class_name Habitat
extends Node

signal measures_updated()
signal measure_change_message(source, message)

const CONFIG_PATH = 'user://gamestate.cfg'

const DAY : int  = 60 * 60 * 24
const WEEK : int = DAY * 5

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
	),
	Job.create(
		'Move waste to reactor',
		'energy',
		123456,
		'Tuesday',
		funcref(self, '_job_feed_reactor')
	),
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
	critters    = clamp(critters    + 2, 1, 18)

func job_begun(job):
	yield(job.change_effect.call_func(), "completed")
	
	emit_signal("measures_updated")

func _job_feed_reactor():
	root.display_job(feed_reactor_scene, { trash_balls = trash_balls })
	var res = yield(root, 'job_finished')

	var up_by = float(ENERGY_USAGE) * res.score
	var new_val = clamp(energy + up_by, 0.0, float(ENERGY_MAX))

	system_update_message("Energy from %.2f%% to %.2f%%, up by %.2f%%" % [100*(energy/ENERGY_MAX), 100*(new_val/ENERGY_MAX), 100*(up_by/ENERGY_MAX)])

	energy = new_val
	trash_balls -= res.total

func _job_rotate_hydroponics():
	root.display_job(maintain_hydroponics_scene, { butterflies = butterflies })
	var score = yield(root, 'job_finished')

	var up_by = float(TERRARIUM_DETERIORATION) * (score / 4)
	var new_val = clamp(terrarium + up_by, 0.0, float(TERRARIUM_MAX))

	system_update_message("Terrarium from %.2f%% to %.2f%%, up by %.2f%%" % [100*(terrarium/TERRARIUM_MAX), 100*(new_val/TERRARIUM_MAX), 100*(up_by/TERRARIUM_MAX)])

	terrarium = new_val

	energy -= float(ENERGY_USAGE) / 2
	trash_balls += 1
	butterflies = clamp(butterflies - score, 6, 999)

func _job_check_life_systems():
	root.display_job(check_life_systems_scene, { critters = critters })
	var res = yield(root, 'job_finished')

	var up_by = float(LIFE_SYSTEMS_WEAR) * (res.o2_score + res.h2o_score)
	var new_val = clamp(life_systems + up_by, 0.0, float(LIFE_SYSTEMS_MAX))

	system_update_message("LifeSystems from %.2f%% to %.2f%%, up by %.2f%%" % [100*(life_systems/LIFE_SYSTEMS_MAX), 100*(new_val/LIFE_SYSTEMS_MAX), 100*(up_by/LIFE_SYSTEMS_MAX)])

	life_systems = new_val

	energy -= float(ENERGY_USAGE)
	trash_balls += 1
	critters = clamp(critters - res.o2_score*10+res.h2o_score*10, 2, 999)

func energy_percent():
	return 100 * (energy / ENERGY_MAX)

func terrarium_percent():
	return 100 * (terrarium / TERRARIUM_MAX)

func life_systems_percent():
	return 100 * (life_systems / LIFE_SYSTEMS_MAX)

func system_update_message(msg):
	emit_signal('measure_change_message', "System update", msg)


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
