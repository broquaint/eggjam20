extends RigidBody2D

func _ready():
	$Move.wait_time = 1.0 + (3.0 * randf())
	$Move.start()

func _process(_delta):
	if $Move.is_stopped():
		apply_central_impulse(Vector2(randi() % 10, randi() % 10))
		$Move.start()
