extends StaticBody2D

@onready var _fade_to_black = $fade_to_black
@onready var _saving_game = $saving_game

var sound_player := AudioStreamPlayer2D.new()

var fade_alpha = 0.0
var fade_step = 0.05

var fade_step_secs = 0.2
var long_step_secs = 6
var timer_fade := Timer.new()

var sleep_start_time = 18
var sleep_end_time = 9

var fading_in = false
var fading_out = false

var player_ref = null

var time_keeper

@export var gives_hp = 1
@export var gives_dash_secs = 20
@export var first_time_sleeping_script : Node = null
var first_time_sleeping = true


# Called when the node enters the scene tree for the first time.
func _ready():
	_saving_game.visible = false
	timer_fade.one_shot = true
	add_child(timer_fade)
	sound_player.bus = "Music"
	add_child(sound_player)
	time_keeper = get_tree().get_first_node_in_group("time_keeper")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_fade_to_black.global_position = Vector2(0,0)
	var player_ref = get_tree().get_first_node_in_group("player")
	if((fading_out || fading_in) &&
	timer_fade.is_stopped()):
		if(fading_out):
			if(fade_alpha < 1):
				fade_alpha +=fade_step
				timer_fade.start(fade_step_secs)
			elif(fade_alpha >= 1):
				fading_out = false
				fading_in = true
				_saving_game.visible = true
				time_keeper.set_clock(sleep_end_time)
				timer_fade.start(long_step_secs)
		elif(fading_in):
			if(fade_alpha > 0):
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
	if(time_keeper.clock > sleep_start_time ||
	time_keeper.clock < sleep_end_time):
		var player_ref = get_tree().get_first_node_in_group("player")
		player_ref.stop()
		player_ref.set_control_frozen(true)
		player_ref.set_ui_invisible()
		update_fade_alpha()
		timer_fade.start(fade_step_secs)
		fading_out = true
		sound_player.global_position = player_ref.global_position
		sound_player.stream = load("res://audio/music/sleep theme.wav")
		sound_player.play()
		var game_save_manager = get_tree().get_first_node_in_group("game_save_manager")
		if(first_time_sleeping):
			first_time_sleeping_script.run_script()
			first_time_sleeping = false
		player_ref.increment_hp()
		player_ref.give_dash_seconds(20)
		time_keeper.advance_day()
		game_save_manager.save_game()

func update_fade_alpha():
	_fade_to_black.color = Color(0,0,0,fade_alpha)
