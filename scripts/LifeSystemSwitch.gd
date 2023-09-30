class_name LifeSystemSwitch

extends Area2D

var o2_on   : Texture = load("res://assets/images/o2 on.png")
var o2_off  : Texture = load("res://assets/images/o2 off.png")
var h2o_on  : Texture = load("res://assets/images/h2o on.png")
var h2o_off : Texture = load("res://assets/images/h2o off.png")

export var is_on : bool
export var system : String

var normal :  Texture
var inverse : Texture
var critter : RigidBody2D

func _ready():
	match system:
		'o2':
			self.normal = o2_on if is_on else o2_off
			self.inverse = o2_off if is_on else o2_on
			self.modulate = Color('#99e550') if is_on else Color('#ac3232')
			$Sprite.texture = normal
		'h2o':
			self.normal = h2o_on if is_on else h2o_off
			self.inverse = h2o_off if is_on else h2o_on
			self.modulate = Color('#99e550') if is_on else Color('#ac3232')
			$Sprite.texture = normal

	$DoSwitch.connect('timeout', self, 'switch_flipped')

func bot_entered():
	$DoSwitch.start()
func bot_left():
	$DoSwitch.stop()

func switch_flipped():
	$Sprite.texture = self.inverse
	is_on = not is_on
	self.modulate = Color('#99e550') if is_on else Color('#ac3232')
	print("switch ", system, " was ", not is_on, " now ", is_on)
