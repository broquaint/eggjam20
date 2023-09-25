extends VBoxContainer

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

func update_measures(clock_time: int):
	energy -= float(clock_time) / float(ENERGY_USAGE)
	$EnergyMeter.rect_size.x = 128 * (energy / 100)

	terrarium -= float(clock_time) / float(TERRARIUM_DETERIORATION)
	$TerrariumMeter.rect_size.x = 128 * (terrarium / 100)
	
	life_systems -= float(clock_time) / float(LIFE_SYSTEMS_WEAR)
	$LifeSystemsMeter.rect_size.x = 128 * (life_systems / 100)
