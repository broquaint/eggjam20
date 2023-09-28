class_name Butterfly

extends RigidBody2D

var can_move = false

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
	if $Move.is_stopped() and can_move:
		flap()
		$Move.start()

func flap():
	var fx = randi() % 15 * (-1 if randi() % 2 == 0 else 1)
	var fy = randi() % 15 * (-1 if randi() % 2 == 0 else 1)
	apply_central_impulse(Vector2(fx, fy))

func start_flapping():
	can_move = true
	flap()

func fly_away():
	var fx = -30 if position.x < 400 else 30
	var fy = -30 if position.y < 300 else 30
	apply_central_impulse(Vector2(fx, fy))
	can_move = false
