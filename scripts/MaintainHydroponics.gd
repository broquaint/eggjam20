extends JobBase

signal play_started()
signal game_completed(score)

enum PlayState {
	AT_START,
	PLAYING,
	ALL_DONE
}

onready var butterfly_scene = preload("res://scenes/Butterfly.tscn")

var play_state

var butterflies = []
var butterfly_total = 10
var score : int = 0

func _ready():
#	randomize()
	play_state = PlayState.AT_START

	$NetForButterflies.position = Vector2(100, 100)
	$NetForButterflies.rotation_degrees = 90
	$NetForButterflies/Catchment.connect("body_entered", self, "catching_butterfly")
	$NetForButterflies/Catchment.connect("body_exited", self, "losing_butterfly")
	$NetForButterflies.connect('player_moved', self, 'start_catching')

	$PlayTime.connect('timeout', self, 'end_game')

	# Workaround for when launching this scene in isolation.
	if has_node('/root/MaintainHydroponics'):
		setup({butterflies=20})

func setup(arguments):
	butterfly_total = arguments.butterflies
	for i in range(1, butterfly_total+1):
		var x = (1 + (i % 4)) * 150
		var y = (1 + floor(i / 4)) * 150
		# Hack to handle lots of butterflies.
		if y >= 600:
			y = (1 + floor((i % 4) / 4)) * 200
		add_butterfly(Vector2(randi() % 100 + x, randi() % 100 + y))
	.job_description("Guide the butterfly portal towards the butterflies using your arrow keys, after a moment in the maw of the portal they will be safely telported back to their home. Don't worry about bumping into them, they are hardy space butterflies!")


func add_butterfly(offset):
#	print("butterfly at ", offset.x, 'x', offset.y)
	var bf = butterfly_scene.instance()
	bf.get_node("EscapeWindow").connect("timeout", self, "caught_butterfly", [bf])
	bf.position = Vector2(offset.x , offset.y)
	connect('play_started', bf, 'start_flapping')
	add_child(bf)
	butterflies.append(bf)
	move_child(bf, 3)
	return bf

func start_catching():
	play_state = PlayState.PLAYING
	$PlayTime.start()
	emit_signal('play_started')

func _process(_delta):
	var time_left = $PlayTime.wait_time if $PlayTime.is_stopped() and play_state < PlayState.ALL_DONE else $PlayTime.time_left
	$Status/TimeLeft.text = '%d:%02d' % [time_left, 100 * fmod(time_left, 1.0)]
	$Status/Score.text = '%d/%d' % [score, butterfly_total]

func catching_butterfly(butterfly):
	if not(butterfly is Butterfly):
		return
	butterfly.get_node('EscapeWindow').start()

func losing_butterfly(butterfly):
	if not(butterfly is Butterfly):
		return
	butterfly.get_node('EscapeWindow').stop()

func caught_butterfly(butterfly):
	if play_state == PlayState.ALL_DONE:
		return

	score += 1

	butterfly.can_move = false
	butterfly.get_node('Collision').disabled = true
	var sprite = butterfly.get_node('Sprite')

	var sb : Tween = butterfly.get_node('Shrink')
	sb.interpolate_property(
		sprite, 'scale', sprite.scale, Vector2.ZERO, 0.5, Tween.TRANS_EXPO, Tween.EASE_OUT
	)
	sb.start()
	yield(sb, "tween_completed")

	butterflies.erase(butterfly)
	butterfly.queue_free()

	if butterflies.empty():
		end_game()

func end_game():
	# Really shouldn't hard code that 24.0!
	.job_summary('Caught %d butterflies of %d in %.2f seconds' % [score, butterfly_total, 24.0 if $PlayTime.is_stopped() else 24.0-$PlayTime.time_left])

	play_state = PlayState.ALL_DONE
	$PlayTime.paused = true
	emit_signal('game_completed', score)

	if not butterflies.empty():
		for wall in [$LeftWall, $RightWall, $TopWall, $BottomWall]:
			wall.get_node('CollisionShape2D').disabled = true
		for bf in butterflies:
			bf.fly_away()
