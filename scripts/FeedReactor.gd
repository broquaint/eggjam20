extends Node2D

enum PlayState {
	AT_START,
	PLAYING,
	FINISHED
}
enum LauncherState {
	READY,
	LAUNCHED
}

var play_state = PlayState.AT_START
var launch_state = LauncherState.READY

onready var trash_ball_scene = preload("res://scenes/TrashBall.tscn")
var trash_ball
var trash_ball_count = 5
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

func _process(_delta):
	if Input.is_action_just_pressed("ui_accept") and launch_state == LauncherState.READY and play_state != PlayState.FINISHED:
		if play_state == PlayState.AT_START and $PlayTime.is_stopped():
			$PlayTime.start()
			play_state = PlayState.PLAYING
		launch_waste()
	var time_left = $PlayTime.wait_time if $PlayTime.is_stopped() else $PlayTime.time_left
	if play_state != PlayState.FINISHED:
		$Status/TimeLeft.text = '%d:%02d' % [time_left, 100 * fmod(time_left, 1.0)]
	$Status/TrashBallCount.text = '%d' % trash_ball_count
	$Status/Score.text = '%d/%d' % [score, trash_ball_total]

func launch_waste():
	trash_ball_count -= 1
	if trash_ball_count == 0:
		play_state = PlayState.FINISHED
	launch_state = LauncherState.LAUNCHED
	trash_ball.apply_central_impulse(Vector2(0, 500).rotated(deg2rad($Trajectory.rotation_degrees)))
	$AnimationPlayer.stop()
	$Reload.start()

func reload():
	if play_state == PlayState.FINISHED:
		return
	launch_state = LauncherState.READY
	trash_ball = trash_ball_scene.instance()
	add_child(trash_ball)
	$AnimationPlayer.play("AimSwing")

func time_over():
	play_state = PlayState.FINISHED

func trash_in_reactor(_node):
	score += 1
func trash_out_reactor(_node):
	score -= 1
