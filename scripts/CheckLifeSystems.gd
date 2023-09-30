extends Node2D

var current_lane = 1

var lanes = [118, 222, 326]
var switch_lanes = [116, 220, 324]
var all_switches = []
var all_critters = []

var o2_total = 0
var h2o_total = 0

onready var switch_scene = load("res://scenes/LifeSystemSwitch.tscn")
onready var critter_scene = load("res://scenes/Critter.tscn")

func make_switch(system, is_on):
	var switch : LifeSystemSwitch = switch_scene.instance()
	switch.system = system
	switch.is_on = is_on
	return switch

func _ready():
#	randomize()
	$Bot.position = Vector2(192, lanes[current_lane])
	$Bot/Sprite.playing = true

	var switches = [
		make_switch('h2o', true),
		make_switch('h2o', false),
		make_switch('o2', true),
		make_switch('o2', false)
	]
	var bag = switches.duplicate()

	for i in range(1,41):
		var rand_switch = bag[randi() % bag.size()]
		
		var new_switch = rand_switch.duplicate()
		new_switch.position = Vector2(256 + (256 * i), switch_lanes[randi() % switch_lanes.size()])
		new_switch.visible = true
		new_switch.connect('body_entered', self, 'switch_entered', [new_switch])
		new_switch.connect('body_exited', self, 'switch_exited', [new_switch])
		add_child(new_switch)
		move_child(new_switch, 2)
		all_switches.append(new_switch)

		match new_switch.system:
			'o2':
				o2_total += 1
			'h2o':
				h2o_total += 1

		if randi() % 2 == 0 and not new_switch.is_on:
			var critter = critter_scene.instance()
			critter.position = new_switch.position
			critter.add_torque(1.0)
			add_child(critter)
			move_child(critter, 2)
			all_critters.append(critter)
			new_switch.critter = critter

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

	var o2_count = 0
	var h2o_count = 0
	for switch in all_switches:
		switch.position.x -= delta * 200
		match switch.system:
			'o2':
				o2_count += 1 if switch.is_on else 0
			'h2o':
				h2o_count += 1 if switch.is_on else 0
	for critter in all_critters:
		critter.position.x -= delta * 200

	$Status/O2Score.text  = '%d/%d' % [o2_count,  o2_total]
	$Status/H2OScore.text = '%d/%d' % [h2o_count, h2o_total]

func animate_lane_switch():
	$SwitchLane.interpolate_property(
		$Bot, 'position',
		$Bot.position, Vector2($Bot.position.x, lanes[current_lane]),
		0.375, Tween.TRANS_BACK, Tween.EASE_OUT
	)
	$SwitchLane.start()

func switch_entered(node, switch):
	var is_critter = 'Critter' in node.name
	if not(node == $Bot or (is_critter and node != switch.critter)):
		return
	if node == $Bot:
		switch.bot_entered()
	if is_critter:
		switch.switch_flipped()
	if switch.critter:
		switch.critter.call_deferred('set_mode', RigidBody2D.MODE_RIGID)
		switch.critter.call_deferred('apply_central_impulse', Vector2(0, 300 + randi() % 300).rotated(deg2rad(randi() % 180)))
		switch.critter.call_deferred('add_torque', 5.0)

func switch_exited(node, switch):
	if node == $Bot:
		switch.bot_left()
