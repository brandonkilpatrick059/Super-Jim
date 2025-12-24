extends Node2D

@export var channel_index : int = 0
@onready var channels_node : Node2D = $channels
@onready var channel_text : Label = $channel_text

var channels : Array[Node] = []

var can_change_channel = true

var audio_player := AudioStreamPlayer.new()

func _ready():
	#channel_text.visible = false
	update_active_channel()
	audio_player.bus = "effects"
	add_child(audio_player)
	var camera_ref = get_tree().get_first_node_in_group("camera")
	camera_ref.fade_in()

func set_channel_index(input : int):
	channel_index = input

func set_can_change_channel(input : bool):
	can_change_channel = input

func handle_input():
	if(can_change_channel):
		if(Input.is_action_just_pressed("up")):
			if(channel_index + 1 < channels.size()):
				channel_index = channel_index + 1
			else:
				channel_index = 0
			audio_player.stream = load("res://audio/soundFX/bigCollide.wav")
			audio_player.play()
		if(Input.is_action_just_pressed("down")):
			if(channel_index - 1 >= 0):
				channel_index = channel_index - 1
			else:
				channel_index = channels.size() - 1
			audio_player.stream = load("res://audio/soundFX/bigCollide.wav")
			audio_player.play()
	update_active_channel()

func update_active_channel():
	var iter = 0 
	for channel in channels:
		if(iter == channel_index):
			channel.set_active(true)
			channel_text.text = channel.get_channel_text()
		else:
			channel.set_active(false)
		iter = iter + 1

func _process(delta: float) -> void:
	if(channels == []):
		channels = channels_node.get_children()
	handle_input()
	channels[channel_index].process()
	
	
