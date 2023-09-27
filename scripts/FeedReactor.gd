extends Node2D

enum LauncherState {
	READY,
	LAUNCHED
}

var launch_state = LauncherState.READY
onready var trash_ball_scene = preload("res://scenes/TrashBall.tscn")
var trash_ball

func _ready():
	$Reload.connect("timeout", self, "reload")
	
	trash_ball = trash_ball_scene.instance()
	remove_child($TrashBall)
	add_child(trash_ball)

func _process(_delta):
	if Input.is_action_just_pressed("ui_accept") and launch_state == LauncherState.READY:
		launch_waste()

func launch_waste():
	launch_state = LauncherState.LAUNCHED
	trash_ball.apply_central_impulse(Vector2(0, 500).rotated(deg2rad($Trajectory.rotation_degrees)))
	$AnimationPlayer.stop()
	$Reload.start()

func reload():
	launch_state = LauncherState.READY
	trash_ball = trash_ball_scene.instance()
	add_child(trash_ball)
	$AnimationPlayer.play("AimSwing")
