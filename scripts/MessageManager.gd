extends ScrollContainer

onready var message_entry_scene : PackedScene = preload("res://scenes/MessageEntry.tscn")

var message_seen = []
func _ready():
	$List.remove_child($List/ExampleA)

func message_received(source, message):
	if not message_seen.empty():
		$List.add_child(HSeparator.new())

	message_seen.append(message)

	var entry = message_entry_scene.instance()
	# Mostly useless but at least adds a few pixels of LHS space!
	entry.add_spacer(true)
	entry.get_node("Source").bbcode_text = '[b]%s[/b]' % source
	entry.get_node('Contents').text = message
	entry.margin_left = 6.0
	$List.add_child(entry)
	
	# via https://github.com/godotengine/godot-proposals/issues/3629
	yield(get_tree(), "idle_frame")
	ensure_control_visible(entry)
