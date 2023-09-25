extends VBoxContainer


func update_measures(clock_time: int):
	$EnergyMeter.rect_size.x = 128 * (Habitat.energy / 100)
	$TerrariumMeter.rect_size.x = 128 * (Habitat.terrarium / 100)
	$LifeSystemsMeter.rect_size.x = 128 * (Habitat.life_systems / 100)
