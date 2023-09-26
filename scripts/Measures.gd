extends VBoxContainer


func update_measures(clock_time: int, _delta):
	$EnergyMeter.rect_size.x = 128 * (Habitat.energy_percent() / 100)
	$TerrariumMeter.rect_size.x = 128 * (Habitat.terrarium_percent() / 100)
#	$LifeSystemsMeter.rect_size.x = 128 * (Habitat.life_systems / 100)
