extends StaticBody2D

@onready var _fade_to_black = $fade_to_black
@onready var _saving_game = $saving_game
@onready var _game_saved_label = $saving_game/saving_game_label
@onready var _door = $saving_game/door

var time_select_bubble = preload("res://dialog/select_bubble.tscn")
var select_time_bubble : Node

var sound_player := AudioStreamPlayer2D.new()

var fade_alpha = 0.0
var fade_step = 0.05

var fade_step_secs = 0.2
var long_step_secs = 6
var timer_fade := Timer.new()

var press_hold_timer := Timer.new()
var holding_forward = false
var teleport_wait_secs = 0.5
var teleporting = false

#these are defined here but they
#are mainly retrieved from the player
#var sleep_start_time = 18
#var sleep_end_time = 9
var sleep_start_hour = 0
var sleep_end_hour = 0

var fading_in = false
var fading_out = false

var player_ref = null

var time_keeper
var begin_dreaming_timer := Timer.new()
var dreaming = false
var dreaming_transition = false
var dreaming_control_return = false

var ui_select_timer := Timer.new()

@export var gives_hp = 1
@export var gives_dash_secs = 20

var no_dream_sleep : bool = false

var time_select_mode : bool = false
var current_select_time : int = 0
var advances_day : bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	_saving_game.visible = false
	timer_fade.one_shot = true
	begin_dreaming_timer.one_shot = true
	add_child(begin_dreaming_timer)
	add_child(timer_fade)
	ui_select_timer.one_shot = true
	add_child(ui_select_timer)
	sound_player.bus = "Effects"
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

func slept_through_night():
	if(advances_day):
		time_keeper.advance_day()
		advances_day = false
	time_keeper.set_clock(sleep_end_hour)
	if(current_select_time > 6):
		player_ref.increment_hp()
		player_ref.give_dash_seconds(20)
	var game_save_manager = get_tree().get_first_node_in_group("game_save_manager")
	game_save_manager.save_game()

func handle_select_time_process():
	var player_ref = get_tree().get_nodes_in_group("player")[0]
	if(ui_select_timer.is_stopped()  && 
	Input.is_action_just_pressed("use_item")):
		var fx_player = get_tree().get_first_node_in_group("main_fx_player")
		fx_player.stream = load("res://audio/soundFX/maracca.ogg")
		fx_player.play()
		end_select_mode()
	elif(ui_select_timer.is_stopped()  && 
	Input.is_action_just_pressed("interact")):
		sleep_start_hour = time_keeper.get_hour()
		sleep_end_hour = sleep_start_hour + current_select_time
		var hours_in_day = 24
		if(sleep_end_hour >= hours_in_day):
			sleep_end_hour = sleep_end_hour - hours_in_day
			advances_day = true
		end_select_mode()
		begin_sleeping()
	else:
		player_ref.stop()
		update_select_bubble()
		var max_time = 24
		if(Input.is_action_just_pressed("menu_right")):
			var fx_player = get_tree().get_first_node_in_group("main_fx_player")
			fx_player.stream = load("res://audio/soundFX/shaker.ogg")
			fx_player.play()
			if(current_select_time < max_time):
				current_select_time = current_select_time + 1
			else:
				current_select_time = 8
		elif(Input.is_action_just_pressed("menu_left")):
			var fx_player = get_tree().get_first_node_in_group("main_fx_player")
			fx_player.stream = load("res://audio/soundFX/shaker.ogg")
			fx_player.play()
			if(current_select_time - 1 <= 0):
				current_select_time = max_time
			else:
				current_select_time = current_select_time - 1

func handle_sleep_process():
	if(_saving_game.visible):
		check_portal_input()
		if(_door.frame == _door.sprite_frames.get_frame_count("open") - 1):
			_door.play("opened")
			dreaming = true
			begin_dreaming_timer.start(4)
		if(!teleporting && holding_forward && press_hold_timer.is_stopped()):
			teleporting = true
			_game_saved_label.visible = false
			var camera = player_ref.get_camera_ref()
			camera.zoom_to(1.25)
			camera.fade_out()
			_door.play("open")
			fading_in = false
			fading_out = false
	if(begin_dreaming_timer.is_stopped()):
		if(dreaming):
			var game_save_manager = get_tree().get_first_node_in_group("game_save_manager")
			game_save_manager.save_game()
			_saving_game.visible = false
			_game_saved_label.visible = true
			fade_alpha = 0.0
			update_fade_alpha()
			player_ref.begin_dreaming()
			dreaming = false
			dreaming_transition = true
			begin_dreaming_timer.start(2)
		elif(dreaming_transition):
			var camera = player_ref.get_camera_ref()
			camera.zoom_to(1.0)
			camera.fade_in()
			dreaming_transition = false
			dreaming_control_return = true
			begin_dreaming_timer.start(2)
		elif(dreaming_control_return):
			dreaming_control_return = false
			teleporting = false
			_door.play("closed")
			player_ref.set_control_frozen(false)
			player_ref.set_movement_frozen(false)
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
				timer_fade.start(long_step_secs)
		elif(fading_in):
			if(!no_dream_sleep):
				no_dream_sleep = true
				slept_through_night()
			if(fade_alpha > 0 && !holding_forward):
				_saving_game.visible = false
				fade_alpha -= fade_step
				timer_fade.start(fade_step_secs)
			elif(fade_alpha <= 0):
				fade_alpha = 0.0
				fading_in = false
				player_ref.set_control_frozen(false)
				player_ref.set_movement_frozen(false)
				player_ref.set_ui_visible()
				var main_fx_player = get_tree().get_first_node_in_group("main_fx_player")
				main_fx_player.fade_in_diagetic_music_bus()
	update_fade_alpha()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#_fade_to_black.global_position = Vector2(0,0)
	player_ref = get_tree().get_first_node_in_group("player")
	if(time_select_mode):
		handle_select_time_process()
	else:
		handle_sleep_process()

func begin_sleeping():
	var main_fx_player = get_tree().get_first_node_in_group("main_fx_player")
	main_fx_player.fade_out_diagetic_music_bus()
	player_ref.set_control_frozen(true)
	player_ref.complete_stop()
	player_ref.set_movement_frozen(true)
	player_ref.set_ui_invisible()
	var camera = player_ref.get_camera_ref()
	#have to add camera pan because select bubble pans the camera, and hasn't
	#yet returned to its initial pos by the time we hit this line of code
	_fade_to_black.global_position = camera.get_screen_center_position() + Vector2(0,camera.get_pan_y_max())
	update_fade_alpha()
	timer_fade.start(fade_step_secs)
	fading_out = true
	var music_player = get_tree().get_first_node_in_group("main_music_player")
	music_player.change_stream("res://audio/music/sleep theme.wav")
	#sound_player.stream = load("res://audio/music/sleep theme.wav")
	#sound_player.play()
	no_dream_sleep = false
	var game_save_manager = get_tree().get_first_node_in_group("game_save_manager")
	game_save_manager.save_game()

func start_select_mode():
	time_select_mode = true
	player_ref.set_control_frozen(true)
	player_ref.stop()
	player_ref.set_dialog_panning(true)
	var fx_player = get_tree().get_first_node_in_group("main_fx_player")
	fx_player.stream = load("res://audio/soundFX/maracca.ogg")
	fx_player.play()
	select_time_bubble = time_select_bubble.instantiate()
	add_child(select_time_bubble)
	select_time_bubble.global_position = player_ref.global_position
	update_select_bubble()
	current_select_time = 1
	ui_select_timer.start(0.2)
	

func end_select_mode():
	var player_ref = get_tree().get_nodes_in_group("player")[0]
	player_ref.set_use_item_timer(0.5)
	player_ref.set_control_frozen(false)
	player_ref.set_dialog_panning(false)
	select_time_bubble.queue_free()
	time_select_mode = false

func update_select_bubble():
	if(select_time_bubble != null):
		var player_ref = get_tree().get_nodes_in_group("player")[0]
		select_time_bubble.global_position = player_ref.global_position
		if(current_select_time == 1):
			select_time_bubble.set_label("Sleep for 1 hour")
		else:
			select_time_bubble.set_label(str("Sleep for ",str(current_select_time, " hours")))

func interact():
	var player_ref = get_tree().get_first_node_in_group("player")
	if(!time_select_mode):
		start_select_mode()
		#begin_sleeping()
	else:
		player_ref._on_make_comment("Can't sleep the day away.")

func update_fade_alpha():
	_fade_to_black.color = Color(0,0,0,fade_alpha)
