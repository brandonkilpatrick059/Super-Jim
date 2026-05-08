extends Node2D

var ui = preload("res://TV/TV_machine.tscn")

@onready var point_light = $PointLight2D
@onready var animated_sprite = $Sprite2D

@export var on : bool = false
@export var channel : int = 0
@export var can_change_channel = false
@export var can_turn_off = true
@export var ambient_sound : String = ""

#0 = daylight
#1 = indoors
#2 = dark
@export var layer_index = 0

var ui_ref = null
var ui_active = false

var player_ref = null

var audio_player := AudioStreamPlayer.new()
@onready var audio_player_2d : AudioStreamPlayer2D = $AudioStreamPlayer2D
var timer := Timer.new()

func _ready() -> void:
	audio_player.bus = "Effects"
	audio_player_2d.bus = "Effects"
	add_child(audio_player_2d)
	add_child(audio_player)
	timer.one_shot = true
	add_child(timer)
	if(ambient_sound != ""):
		audio_player_2d.stream = load(ambient_sound)
		audio_player_2d.play()

func get_layer_index():
	return layer_index

func set_up_ui():
	if(player_ref != null):
		ui_ref.set_channel_index(channel)
		ui_ref.set_can_change_channel(can_change_channel)
		ui_ref.set_layer_index(layer_index)

func interact():
	if(on && timer.is_stopped()):
		var main_fx_player = get_tree().get_first_node_in_group("main_fx_player")
		main_fx_player.fade_out_diagetic_music_bus()
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
		add_to_group("lookable")
		audio_player.stream = load("res://audio/soundFX/smallCollide.wav")
		audio_player.play()

func handle_input():
	pass

func exit_ui():
	ui_active = false
	ui_ref.clean_up()
	ui_ref.queue_free()
	player_ref.set_control_frozen(false)
	player_ref.main_ui_visible()
	var camera_ref = player_ref.get_camera_ref()
	audio_player_2d.play()
	camera_ref.fade_in()
	var main_fx_player = get_tree().get_first_node_in_group("main_fx_player")
	main_fx_player.fade_in_diagetic_music_bus()

func _physics_process(delta: float) -> void:
	if(on):
		animated_sprite.play("on")
		point_light.enabled = true
		if(!is_in_group("lookable")):
			add_to_group("lookable")
	else:
		animated_sprite.play("off")
		point_light.enabled = false
	if(ui_active):
		audio_player_2d.stop()
		ui_ref.global_position = player_ref.get_camera_ref().get_screen_center_position()
		if Input.is_action_just_pressed("menu_back"):
			timer.start(1)
			ui_ref.reset_camera()
			exit_ui()
			player_ref.start_control_lockout_timer(0.25)
			if(can_turn_off):
				on = false
				remove_from_group("lookable")
			audio_player.stream = load("res://audio/soundFX/smallCollide.wav")
			audio_player.play()
