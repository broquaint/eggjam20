extends KinematicBody2D

signal player_moved()

const THRUST : float = 6.0
const MAX_SPEED : float = 200.0
const ROTATION_SPEED : float = 3.0 * 60

var velocity : Vector2
var has_moved = false

func _physics_process(delta):
	# move_down isn't used but this is nice'n'easy.
	var iv = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if iv != Vector2.ZERO and not has_moved:
		has_moved = true
		emit_signal("player_moved")
	if Input.is_action_pressed("move_left"):
		rotation_degrees -= delta * ROTATION_SPEED
	elif Input.is_action_pressed("move_right"):
		rotation_degrees += delta * ROTATION_SPEED

	if Input.is_action_pressed("move_up"):
		var acceleration : Vector2

		# -THRUST because vector pointing up = y value of -1
		acceleration = Vector2(0, -THRUST).rotated(deg2rad(rotation_degrees))
		velocity += acceleration

	# dampen a bit
	velocity *= 0.985

	# cap speed
	if velocity.length() > MAX_SPEED:
		velocity = velocity.normalized() * MAX_SPEED

	var collision = move_and_collide(velocity * delta)
	if collision:
		velocity = velocity.bounce(collision.normal)
