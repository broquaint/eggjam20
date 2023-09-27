extends Node2D

signal game_completed(ball_total, score)

enum PlayState {
	AT_START,
	PLAYING,
	TRASH_FINISHED,
	ALL_DONE
}
enum LauncherState {
	READY,
	LAUNCHED
}

var play_state = PlayState.AT_START
var launch_state = LauncherState.READY

onready var trash_ball_scene = preload("res://scenes/TrashBall.tscn")
var trash_ball
var trash_balls = []
# This tracks how many are left to launch.
var trash_ball_count = 5
# This could be variable, may build up over time.
var trash_ball_total = 5

var score = 0

func _ready():
	$Reload.connect("timeout", self, "reload")
	$PlayTime.connect("timeout", self, "time_over")
	$ReactorInput.connect("body_entered", self, "trash_in_reactor")
	$ReactorInput.connect("body_exited", self, "trash_out_reactor")

	# This exists purely for visual reference, could just delete it from the tree.
	remove_child($TrashBall)

	trash_ball = trash_ball_scene.instance()
	add_child(trash_ball)
	trash_balls.append(trash_ball)

func _process(_delta):
	if Input.is_action_just_pressed("ui_accept") and launch_state == LauncherState.READY and play_state != PlayState.TRASH_FINISHED:
		if play_state == PlayState.AT_START and $PlayTime.is_stopped():
			$PlayTime.start()
			play_state = PlayState.PLAYING
			$ReactorAnimationPlayer.play("StartReactor")
		launch_waste()
	var time_left = $PlayTime.wait_time if $PlayTime.is_stopped() and play_state < PlayState.TRASH_FINISHED else $PlayTime.time_left
	if play_state != PlayState.TRASH_FINISHED:
		$Status/TimeLeft.text = '%d:%02d' % [time_left, 100 * fmod(time_left, 1.0)]
	$Status/TrashBallCount.text = '%d' % trash_ball_count
	$Status/Score.text = '%d/%d' % [score, trash_ball_total]

func launch_waste():
	trash_ball_count -= 1
	if trash_ball_count == 0:
		end_game()
	launch_state = LauncherState.LAUNCHED
	trash_ball.mode = RigidBody.MODE_RIGID
	trash_ball.apply_central_impulse(Vector2(0, 500).rotated(deg2rad($Trajectory.rotation_degrees)))
	$SwingAnimationPlayer.stop()
	$Reload.start()

func reload():
	if play_state == PlayState.TRASH_FINISHED:
		return
	launch_state = LauncherState.READY
	trash_ball = trash_ball_scene.instance()
	add_child(trash_ball)
	trash_balls.append(trash_ball)
	$SwingAnimationPlayer.play("AimSwing")

func time_over():
	if play_state != PlayState.TRASH_FINISHED:
		end_game()

func end_game():
	play_state = PlayState.TRASH_FINISHED
	if not $PlayTime.is_stopped():
		$PlayTime.paused = true
	$SwingAnimationPlayer.stop(false)
	# Wait some time for things to play out then call it whatever state.
	yield(get_tree().create_timer(3.0), 'timeout')
	play_state = PlayState.ALL_DONE
	$ReactorAnimationPlayer.play("StopReactor")
	for ball in trash_balls:
		if ball.in_reactor:
			var shrink = get_tree().create_tween()
			shrink.tween_property(ball.get_node('Sprite'), 'scale', Vector2.ZERO, 1.0)
			shrink.set_parallel()
	emit_signal("game_completed", trash_ball_total, score)

func trash_in_reactor(ball):
	if play_state == PlayState.ALL_DONE:
		return

	score += 1
	var ct : Tween = ball.get_node('ColdTrash')
	ct.stop_all()
	var ht : Tween = ball.get_node('HotTrash')
	ht.interpolate_property(
		ball, 'modulate', ball.modulate, Color('#d95763'), 1.5, Tween.TRANS_CUBIC, Tween.EASE_OUT_IN, 0.5
	)
	ht.start()
	ball.in_reactor = true

func trash_out_reactor(ball):
	if play_state == PlayState.ALL_DONE:
		return

	score -= 1
	var ht : Tween = ball.get_node('HotTrash')
	ht.stop_all()
	var ct : Tween = ball.get_node('ColdTrash')
	ct.interpolate_property(
		ball, 'modulate', ball.modulate, Color('#ffffff'), 1.5, Tween.TRANS_LINEAR, Tween.EASE_IN, 0.5
	)
	ct.start()
	ball.in_reactor = false
