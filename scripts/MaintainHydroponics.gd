extends Node2D

signal play_started()

enum PlayState {
	AT_START,
	PLAYING,
	ALL_DONE
}

onready var butterfly_scene = preload("res://scenes/Butterfly.tscn")

var play_state

var butterflies = []
var score : int = 0

func _ready():
	play_state = PlayState.AT_START
	for i in range(1, 4):
		add_butterfly(Vector2((i+1) * 100, (i+1) * 100))

	$NetForButterflies.position = Vector2(100, 100)
	$NetForButterflies.rotation_degrees = 90
	$NetForButterflies/Catchment.connect("body_entered", self, "catching_butterfly")
	$NetForButterflies/Catchment.connect("body_exited", self, "losing_butterfly")
	$NetForButterflies.connect('player_moved', self, 'start_catching')

func add_butterfly(offset):
	var bf = butterfly_scene.instance()
	bf.get_node("EscapeWindow").connect("timeout", self, "caught_butterfly", [bf])
	bf.position = Vector2(offset.x + randi() % 50, offset.y + randi() % 50)
	connect('play_started', bf, 'start_flapping')
	add_child(bf)
	butterflies.append(bf)

func start_catching():
	play_state = PlayState.PLAYING
	$PlayTime.start()
	emit_signal('play_started')

func _process(_delta):
	var time_left = $PlayTime.time_left
	$Status/TimeLeft.text = '%d:%02d' % [time_left, 100 * fmod(time_left, 1.0)]
	$Status/Score.text = '%d' % score

func catching_butterfly(butterfly):
	if not(butterfly is Butterfly):
		return
	butterfly.get_node('EscapeWindow').start()

func losing_butterfly(butterfly):
	if not(butterfly is Butterfly):
		return
	butterfly.get_node('EscapeWindow').stop()

func caught_butterfly(butterfly):
	score += 1

	butterfly.get_node('Collision').disabled = true
	var sprite = butterfly.get_node('Sprite')

	var sb : Tween = butterfly.get_node('Shrink')
	sb.interpolate_property(
		sprite, 'scale', sprite.scale, Vector2.ZERO, 0.5, Tween.TRANS_EXPO, Tween.EASE_IN
	)
	sb.start()
	yield(sb, "tween_completed")

	butterflies.erase(butterfly)
	butterfly.queue_free()

	var x = 400 + randi() % 150 * (-1 if randi() % 2 == 0 else 1)
	var y = 300 + randi() % 150 * (-1 if randi() % 2 == 0 else 1)
	add_butterfly(Vector2(x, y))
