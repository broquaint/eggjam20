extends Node2D

var current_lane = 1

var lanes = [118, 222, 326]
var switch_lanes = [116, 220, 324]
var all_switches = []

onready var switch_scene = load("res://scenes/LifeSystemSwitch.tscn")

func make_switch(system, is_on):
	var switch : LifeSystemSwitch = switch_scene.instance()
	switch.system = system
	switch.is_on = is_on
	return switch

func _ready():
	randomize()
	$Bot.position = Vector2(192, lanes[current_lane])
	$Bot/Sprite.playing = true
#	var switches = [$H2oOn, $H2oOff, $O2On, $O2Off]
	var switches = [
		make_switch('h2o', true),
		make_switch('h2o', false),
		make_switch('o2', true),
		make_switch('o2', false)
	]
	var bag = switches.duplicate()
	for i in range(1,40):
		var rand_switch = bag[randi() % bag.size()]
		
		var new_switch = rand_switch.duplicate()
		new_switch.position = Vector2(256 + (256 * i), switch_lanes[randi() % switch_lanes.size()])
		new_switch.visible = true
		new_switch.connect('area_entered', self, 'switch_entered', [new_switch])
		new_switch.connect('area_exited', self, 'switch_exited', [new_switch])
		# TODO make use of this signal for live updates
		# new_switch.connect('switch_flipped', self, 'system_change')
		add_child(new_switch)
		move_child(new_switch, 2)
		all_switches.append(new_switch)

		bag.erase(rand_switch)
		if bag.empty():
			bag = switches.duplicate()

func _process(delta):
	if not $SwitchLane.is_active():
		if Input.is_action_just_pressed("move_up") and current_lane > 0:
			current_lane -= 1
			animate_lane_switch()
		elif Input.is_action_just_pressed("move_down") and current_lane < 2:
			current_lane += 1
			animate_lane_switch()
	for switch in all_switches:
		switch.position.x -= delta * 200

func animate_lane_switch():
	$SwitchLane.interpolate_property(
		$Bot, 'position',
		$Bot.position, Vector2($Bot.position.x, lanes[current_lane]),
		0.5, Tween.TRANS_BACK, Tween.EASE_OUT
	)
	$SwitchLane.start()

func switch_entered(node, switch):
	if node == $Bot:
		switch.bot_entered()

func switch_exited(node, switch):
	if node == $Bot:
		switch.bot_left()
