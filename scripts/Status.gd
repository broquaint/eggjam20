extends HBoxContainer

const WEEKDAYS = [
	'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday' #, 'Saturday', 'Sunday'
]
const MONTHS = [
	'September', 'October', 'November', 'December', 'January',
	'February', 'March', 'April', 'May', 'June', # 'July', 'August'
]

var weekday = 0
var monthday = 24
var month = 0
var year = 2566

func _ready():
	set_calendar()

func update_clock(clock_time, _delta):
	var hours = int(floor(clock_time / 3600)) if clock_time > 0 else 0
	clock_time -= hours * 3600
	var minutes = int(floor(clock_time / 60)) if clock_time > 0 else 0
	clock_time -= minutes * 60
	$Time.text = '%02d:%02d:%02d' % [hours, minutes, clock_time]

func update_date():
	var nextday = monthday + 1
	if nextday > 30:
		monthday = 1
		month += 1
	else:
		monthday += 1
	weekday = (weekday + 1) % WEEKDAYS.size()
	set_calendar()

func set_calendar():
	$WeekDay.text = WEEKDAYS[weekday]
	$MonthDay.text = '%d' % monthday
	$Month.text = MONTHS[month]
	$Year.text = '2566'
