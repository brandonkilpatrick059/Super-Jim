extends Node2D

var ui = preload("res://TV/TV_machine.tscn")

@onready var point_light = $PointLight2D
@onready var animated_sprite = $Sprite2D

@export var on : bool = false
@export var channel : int = 0
@export var can_change_channel = false
@export var can_turn_off = true

#0 = daylight
#1 = indoors
#2 = dark
@export var layer_index = 0

var ui_ref = null
var ui_active = false

var player_ref = null

var audio_player := AudioStreamPlayer.new()
var timer := Timer.new()

func _ready() -> void:
	audio_player.bus = "Effects"
	add_child(audio_player)
	timer.one_shot = true
	add_child(timer)

func get_layer_index():
	return layer_index

func set_up_ui():
	if(player_ref != null):
		ui_ref.set_channel_index(channel)
		ui_ref.set_can_change_channel(can_change_channel)
		ui_ref.set_layer_index(layer_index)

func interact():
	if(on && timer.is_stopped()):
		player_ref = get_tree().get_first_node_in_group("player")
		ui_ref = ui.instantiate()
		player_ref.set_control_frozen(true)
		player_ref.main_ui_invisible()
		ui_ref.global_position = player_ref.get_camera_ref().get_screen_center_position()
		set_up_ui()
		player_ref.get_parent().add_child(ui_ref)
		ui_active = true
	elif(timer.is_stopped()):
		on = true
		audio_player.stream = load("res://audio/soundFX/smallCollide.wav")
		audio_player.play()

func handle_input():
	pass

func exit_ui():
	ui_active = false
	ui_ref.queue_free()
	player_ref.set_control_frozen(false)
	player_ref.main_ui_visible()
	var camera_ref = player_ref.get_camera_ref()
	camera_ref.fade_in()

func _physics_process(delta: float) -> void:
	if(on):
		animated_sprite.play("on")
		point_light.enabled = true
	else:
		animated_sprite.play("off")
		point_light.enabled = false
	if(ui_active):
		ui_ref.global_position = player_ref.get_camera_ref().get_screen_center_position()
		if Input.is_action_just_pressed("interact"):
			timer.start(1)
			ui_ref.reset_camera()
			exit_ui()
			if(can_turn_off):
				on = false
			audio_player.stream = load("res://audio/soundFX/smallCollide.wav")
			audio_player.play()
