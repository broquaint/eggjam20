extends HBoxContainer

func update_clock(clock_time, _delta):
	var hours = int(floor(clock_time / 3600)) if clock_time > 0 else 0
	clock_time -= hours * 3600
	var minutes = int(floor(clock_time / 60)) if clock_time > 0 else 0
	clock_time -= minutes * 60
	$Time.text = '%02d:%02d:%02d' % [hours, minutes, clock_time]

func update_date(day):
	# TODO - Actual calendar stuff.
	$Date.text = 'Monday %dth September' % day
