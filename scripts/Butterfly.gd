class_name Butterfly

extends RigidBody2D

const COLOURS = [
	Color('#df7126'),
	Color('#dc6ea5'),
	Color('#6ec8fa'),
	Color('#96f06e')
]

func _ready():
	$Sprite.modulate = COLOURS[randi() % COLOURS.size()]
	$Move.wait_time = 0.5 + (3.0 * randf())
	$Move.start()

func _process(_delta):
	if $Move.is_stopped():
		var fx = randi() % 15 * (-1 if randi() % 2 == 0 else 1)
		var fy = randi() % 15 * (-1 if randi() % 2 == 0 else 1)
		apply_central_impulse(Vector2(fx, fy))
		$Move.start()