extends StaticBody2D

@onready var _fade_to_black = $fade_to_black
@onready var _saving_game = $saving_game
@onready var _game_saved_label = $saving_game/saving_game_label
@onready var _door = $saving_game/door

var sound_player := AudioStreamPlayer2D.new()

var fade_alpha = 0.0
var fade_step = 0.05

var fade_step_secs = 0.2
var long_step_secs = 6
var timer_fade := Timer.new()

var press_hold_timer := Timer.new()
var holding_forward = false
var teleport_wait_secs = 1.5
var teleporting = false

var sleep_start_time = 18
var sleep_end_time = 9

var fading_in = false
var fading_out = false

var player_ref = null

var time_keeper

@export var gives_hp = 1
@export var gives_dash_secs = 20


# Called when the node enters the scene tree for the first time.
func _ready():
	_saving_game.visible = false
	timer_fade.one_shot = true
	add_child(timer_fade)
	sound_player.bus = "Music"
	add_child(sound_player)
	time_keeper = get_tree().get_first_node_in_group("time_keeper")
	press_hold_timer.one_shot = true
	add_child(press_hold_timer)

func check_portal_input():
	if(!holding_forward && Input.is_action_just_pressed("up")):
		holding_forward = true
		press_hold_timer.start(teleport_wait_secs)
	elif(holding_forward && Input.is_action_just_released("up")):
		holding_forward = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#_fade_to_black.global_position = Vector2(0,0)
	var player_ref = get_tree().get_first_node_in_group("player")
	if(_saving_game.visible):
		check_portal_input()
		if(_door.frame == _door.sprite_frames.get_frame_count("open") - 1):
			_door.play("opened")
		if(!teleporting && holding_forward && press_hold_timer.is_stopped()):
			teleporting = true
			_game_saved_label.visible = false
			var camera = player_ref.get_camera_ref()
			camera.zoom_to(1.25)
			camera.fade_out()
			_door.play("open")
			
	if((fading_out || fading_in) &&
	timer_fade.is_stopped()):
		if(fading_out):
			if(fade_alpha < 1):
				fade_alpha +=fade_step
				timer_fade.start(fade_step_secs)
			elif(fade_alpha >= 1):
				fading_out = false
				fading_in = true
				var camera = player_ref.get_camera_ref()
				_saving_game.global_position = camera.get_screen_center_position()
				_saving_game.visible = true
				time_keeper.set_clock(sleep_end_time)
				timer_fade.start(long_step_secs)
		elif(fading_in):
			if(fade_alpha > 0 && !holding_forward):
				_saving_game.visible = false
				fade_alpha -= fade_step
				timer_fade.start(fade_step_secs)
			elif(fade_alpha <= 0):
				fade_alpha = 0.0
				fading_in = false
				player_ref.set_control_frozen(false)
				player_ref.set_ui_visible()
	update_fade_alpha()

func interact():
	var player_ref = get_tree().get_first_node_in_group("player")
	if(time_keeper.clock > sleep_start_time ||
	time_keeper.clock < sleep_end_time):
		player_ref.stop()
		player_ref.set_control_frozen(true)
		player_ref.set_ui_invisible()
		var camera = player_ref.get_camera_ref()
		_fade_to_black.global_position = camera.get_screen_center_position()
		update_fade_alpha()
		timer_fade.start(fade_step_secs)
		fading_out = true
		sound_player.global_position = player_ref.global_position
		sound_player.stream = load("res://audio/music/sleep theme.wav")
		sound_player.play()
		var game_save_manager = get_tree().get_first_node_in_group("game_save_manager")
		player_ref.increment_hp()
		player_ref.give_dash_seconds(20)
		time_keeper.advance_day()
		game_save_manager.save_game()
	else:
		player_ref._on_make_comment("Can't sleep the day away.")

func update_fade_alpha():
	_fade_to_black.color = Color(0,0,0,fade_alpha)
