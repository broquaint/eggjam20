extends VBoxContainer

func _ready() -> void:
	$Status.text = 'Jobs 0/%d' % $Jobs.get_child_count()

func job_start(_job):
	update_status()

func job_end(_res):
	update_status()
	
func update_status():
	var count = 0
	for jb in $Jobs.get_children():
		if jb.pressed:
			count += 1
	$Status.text = 'Jobs %d/%d' % [count, $Jobs.get_child_count()]
