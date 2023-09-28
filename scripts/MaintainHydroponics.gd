extends Node2D

onready var butterfly_scene = preload("res://scenes/Butterfly.tscn")

var butterflies = []

func _ready():
	for i in range(1, 4):
		add_butterfly(Vector2((i+1) * 100, (i+1) * 100))

	$NetForButterflies.position = Vector2(100, 100)
	$NetForButterflies/Catchment.connect("body_entered", self, "catching_butterfly")
	$NetForButterflies/Catchment.connect("body_exited", self, "losing_butterfly")

func add_butterfly(offset):
	var bf = butterfly_scene.instance()
	bf.get_node("EscapeWindow").connect("timeout", self, "caught_butterfly", [bf])
	bf.position = Vector2(offset.x + randi() % 50, offset.y + randi() % 50)
	add_child(bf)
	butterflies.append(bf)

func catching_butterfly(butterfly):
	if not(butterfly is Butterfly):
		return
	butterfly.get_node('EscapeWindow').start()

func losing_butterfly(butterfly):
	if not(butterfly is Butterfly):
		return
	butterfly.get_node('EscapeWindow').stop()

func caught_butterfly(butterfly):
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
