extends VBoxContainer

func tick_update_measures(_clock_time: int, _delta: int):
	update_measures()

func change_update_measures():
	update_measures()

func update_measures():
	$EnergyMeter.rect_size.x = 128 * (Habitat.energy_percent() / 100)
	$TerrariumMeter.rect_size.x = 128 * (Habitat.terrarium_percent() / 100)
	#	$LifeSystemsMeter.rect_size.x = 128 * (Habitat.life_systems / 100)
