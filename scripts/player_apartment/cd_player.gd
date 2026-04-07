extends Node2D

var ui = preload("res://interface/cd_player_interface.tscn")

@onready var animated_sprite = $AnimatedSprite2D

@export var on : bool = false
@export var can_interact = true
@export var chosen_music_key : String = ""

@onready var audio_player_2d : AudioStreamPlayer2D = $AudioStreamPlayer2D
var timer := Timer.new()

var ui_ref = null
var ui_active = false 

var giving_control_back : bool = false

@export var music_index = 0

var music_keys : Array[String] = [
	"chill_out",
	"bandit"
]

var stream_map : Array[String] = [
	"res://audio/music/chill_out_theme.wav",
	"res://audio/music/bandit_game_song.wav"
]

func _ready() -> void:
	timer.one_shot = true
	add_child(timer)
	if(!can_interact):
		play_chosen_key()

func set_up_ui():
	var player_ref = get_tree().get_first_node_in_group("player")
	ui_ref = ui.instantiate()
	player_ref.set_control_frozen(true)
	player_ref.main_ui_invisible()
	ui_ref.global_position = player_ref.get_camera_ref().get_screen_center_position()
	player_ref.set_control_frozen(true)
	player_ref.main_ui_invisible()
	player_ref.get_parent().add_child(ui_ref)
	ui_active = true

func play_current_index():
	var player_ref = get_tree().get_first_node_in_group("player")
	var owned_music = player_ref.get_owned_music()
	if(owned_music.size() > 0):
		if(music_index < owned_music.size()):
			var owned_key = owned_music[music_index]
			var key_index = music_keys.find(owned_key)
			var stream = stream_map[key_index]
			audio_player_2d.stream = load(stream)
			audio_player_2d.play()

func play_chosen_key():
	var key_index = music_keys.find(chosen_music_key)
	var stream = stream_map[key_index]
	audio_player_2d.stream = load(stream)
	audio_player_2d.play()

func stop_playing_music():
	audio_player_2d.stop()

func close_ui():
	giving_control_back = true
	timer.start(0.25)
	ui_active = false
	ui_ref.queue_free()

func interact():
	if(can_interact):
		if(!on && timer.is_stopped()):
			set_up_ui()
			on = true
			play_current_index()
		elif(on && timer.is_stopped()):
			on = false
			stop_playing_music()
			audio_player_2d.stream = load("res://audio/soundFX/smallCollide.wav")
			audio_player_2d.play()
		timer.start(0.25)

func update_ui():
	var player_ref = get_tree().get_first_node_in_group("player")
	var owned_music = player_ref.get_owned_music()
	if(owned_music.size() > 0):
		var current_key = owned_music[music_index]
		ui_ref.set_cover(current_key)

func handle_input():
	if(ui_active && timer.is_stopped()):
		var player_ref = get_tree().get_first_node_in_group("player")
		var owned_music = player_ref.get_owned_music()
		if(owned_music.size() > 1):
			if(Input.is_action_just_pressed("left")):
				if(music_index ==  0):
					music_index = owned_music.size() - 1
				else:
					music_index = music_index - 1
				timer.start(0.25)
				play_current_index()
			elif(Input.is_action_just_pressed("right")):
				if(music_index ==  owned_music.size() - 1):
					music_index = 0
				else:
					music_index = music_index + 1
				timer.start(0.25)
				play_current_index()
		if(Input.is_action_just_pressed("interact") || 
		Input.is_action_just_pressed("use_item")):
			close_ui()
			timer.start(0.25)

func _physics_process(delta: float) -> void:
	if(ui_active):
		update_ui()
		handle_input()
	if(on):
		animated_sprite.play("active")
	else:
		animated_sprite.play("inactive")
	if(giving_control_back && timer.is_stopped()):
		var player_ref = get_tree().get_first_node_in_group("player")
		player_ref.set_control_frozen(false)
		player_ref.main_ui_visible()
		giving_control_back = false
