extends Node2D

@export var channel_index : int = 0
@onready var channels_node : Node2D = $channels
@onready var channel_text : Label = $channel_text

var channels : Array[Node] = []

func _ready():
	#channel_text.visible = false
	update_active_channel()

func handle_input():
	update_active_channel()

func update_active_channel():
	var iter = 0 
	for channel in channels:
		if(iter == channel_index):
			channel.set_active(true)
		else:
			channel.set_active(false)

func _process(delta: float) -> void:
	if(channels == []):
		channels = channels_node.get_children()
	handle_input()
	channels[channel_index].process()
	
	
