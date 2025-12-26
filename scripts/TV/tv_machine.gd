extends Node2D

@export var channel_index : int = 0
@onready var channels_node : Node2D = $channels
@onready var channel_text : Label = $channel_text
@onready var back_ground : Sprite2D = $back_ground

var channels : Array[Node] = []

var can_change_channel = true

var audio_player := AudioStreamPlayer.new()

var camera_ref = null 

var layer_index : int = 0

var camera_should_reset : bool = false

func _ready():
	#channel_text.visible = false
	update_active_channel()
	audio_player.bus = "Effects"
	add_child(audio_player)
	var camera_ref = get_tree().get_first_node_in_group("camera")
	camera_ref.fade_in()

func show_back_ground(input : bool):
	back_ground.visible = input

func back_ground_visible():
	return back_ground.visible

func set_channel_index(input : int):
	channel_index = input

func set_can_change_channel(input : bool):
	can_change_channel = input

func set_layer_index(input : int):
	layer_index = input

func start_reset_camera():
	camera_should_reset = true
	show_back_ground(true)

func reset_camera():
	var daylight_layer = get_tree().get_first_node_in_group("daylight_layer")
	var dark_layer = get_tree().get_first_node_in_group("dark_layer")
	match layer_index:
		0:
			daylight_layer.visible = true
			dark_layer.visible = false
		1:
			daylight_layer.visible = false
			dark_layer.visible = false
		2:
			daylight_layer.visible = false
			dark_layer.visible = true
	var camera_ref = get_tree().get_first_node_in_group("camera")
	var player_ref = get_tree().get_first_node_in_group("player")
	camera_ref.connect_anchor(player_ref)

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

func _physics_process(delta: float) -> void:
	if(back_ground_visible() && camera_should_reset):
		reset_camera()
		camera_should_reset = false

func _process(delta: float) -> void:
	if(channels == []):
		channels = channels_node.get_children()
	handle_input()
	channels[channel_index].process()
	if(camera_ref == null):
		camera_ref = get_tree().get_first_node_in_group("camera")
	global_position = camera_ref.get_screen_center_position()
