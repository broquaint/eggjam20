extends JobBase

signal play_started()
signal game_completed(o2_score, h2o_score)

enum PlayState {
	AT_START,
	PLAYING,
	ALL_DONE
}

var play_state
var current_lane = 1

var lanes = [118, 222, 326]
var switch_lanes = [116, 220, 324]

var switch_speed = 0
var switch_speed_max = 250

var all_switches = []
var all_critters = []

var o2_total = 10
var h2o_total = 10
var critter_total = 0

onready var switch_scene = load("res://scenes/LifeSystemSwitch.tscn")
onready var critter_scene = load("res://scenes/Critter.tscn")


func _ready():
	play_state = PlayState.AT_START
#	randomize()
	$Bot.position = Vector2(192, lanes[current_lane])
	$Bot/Sprite.playing = true

func make_switch(system, is_on):
	var switch : LifeSystemSwitch = switch_scene.instance()
	switch.setup(system, is_on)
	return switch

func setup(arguments):
	var new_switches = []
	for _i in range(0, 10):
		new_switches.append(make_switch('o2', true))
		new_switches.append(make_switch('h2o', true))

	var rand_indices = range(0, 20)
	rand_indices.shuffle()
	var critter_indices = rand_indices.slice(0, arguments.critters-1)
	for idx in critter_indices:
		new_switches[idx].switch_flipped()

	for i in range(0, new_switches.size()):
		var new_switch = new_switches[randi() % new_switches.size()]
		new_switch.position = Vector2(256 + (256 * (i+1)), switch_lanes[randi() % switch_lanes.size()])
		new_switch.visible = true
		new_switch.connect('body_entered', self, 'switch_entered', [new_switch])
		new_switch.connect('body_exited', self, 'switch_exited', [new_switch])
		add_child(new_switch)
		move_child(new_switch, 2)
		all_switches.append(new_switch)

		if not new_switch.is_on:
			var critter = critter_scene.instance()
			critter.position = new_switch.position
			critter.add_torque(1.0)
			add_child(critter)
			move_child(critter, 2)
			all_critters.append(critter)
			new_switch.critter = critter

		new_switches.erase(new_switch)

func _process(delta):
	if Input.is_action_just_pressed("move_up") or Input.is_action_just_pressed("move_down"):
		play_state = PlayState.PLAYING
		emit_signal('play_started')
		var speed_up = get_tree().create_tween()
		speed_up.tween_property(self, 'switch_speed', switch_speed_max, 1.5)

	if play_state == PlayState.AT_START:
		return

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
		switch.position.x -= delta * switch_speed
		match switch.system:
			'o2':
				o2_count += 1 if switch.is_on else 0
			'h2o':
				h2o_count += 1 if switch.is_on else 0
	for critter in all_critters:
		critter.position.x -= delta * switch_speed

	$Status/O2Score.text  = '%d/%d' % [o2_count,  o2_total]
	$Status/H2OScore.text = '%d/%d' % [h2o_count, h2o_total]

	if play_state != PlayState.ALL_DONE and all_switches.back().position.x < 0:
		play_state = PlayState.ALL_DONE
		.job_summary('O2 switches: %d/%d, H20 switches: %d/%d' % [o2_count, o2_total, h2o_count, h2o_total])
		emit_signal('game_completed', {o2_score = o2_total/o2_count, h2o_score = h2o_total/h2o_count})

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
