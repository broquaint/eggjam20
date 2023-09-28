extends VBoxContainer

func _ready():
	for child in get_children():
		if child is SplitContainer:
			child.get_node('Name').text = child.name

func tick_update_measures(_clock_time: int, _delta: int):
	update_measures()

func change_update_measures():
	update_measures()

func update_measures():
	$Energy/Value/Current.rect_size.x = 128 * (Habitat.energy_percent() / 100)
	$Terrarium/Value/Current.rect_size.x = 128 * (Habitat.terrarium_percent() / 100)
	#	$LifeSystemsMeter.rect_size.x = 128 * (Habitat.life_systems / 100)
