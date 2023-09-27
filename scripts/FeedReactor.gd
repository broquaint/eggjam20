extends Node2D


func _process(_delta):
	if Input.is_action_just_pressed("ui_accept"):
		launch_waste()

func launch_waste():
#	$TrashBall.applied_force = Vector2(0, 500).rotated(deg2rad($Trajectory.rotation_degrees))
	$TrashBall.apply_central_impulse(Vector2(0, 500).rotated(deg2rad($Trajectory.rotation_degrees)))
	$AnimationPlayer.stop()
