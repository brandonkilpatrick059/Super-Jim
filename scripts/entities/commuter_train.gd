extends Sprite2D

@onready var sound_player : AudioStreamPlayer2D = $AudioStreamPlayer2D

var move_step = 6
var move_timer_step = 0.006
var move_step_timer : Timer = Timer.new()

var station_timer : Timer = Timer.new()
var station_wait_secs = 15

var going_east = true
var returning_east = false
var going_west = false
var returning_west = false

var east_station_leave_times : Array[int] = [9,17]
var wast_station_leave_times : Array[int] = [13,20]
var eastbound_leave_times : Array[int] = [7,15]
var westbound_leave_times : Array[int] = [11,19]

var east_station_x = 6000
var west_station_x = -4500
var initial_x

var shake_camera : bool = true

func sound_player_is_playing():
	return sound_player.playing

func _ready() -> void:
	move_step_timer.one_shot = true
	add_child(move_step_timer)
	
	station_timer.one_shot = true
	add_child(station_timer)
	
	initial_x = global_position.x
	sound_player.stop()

#TODO: get this to work in a way that doesn't look bad
func handle_camera_shake():
	var player = get_tree().get_first_node_in_group("player")
	var distance = global_position.distance_to(player.global_position)
	var shake_distance = 64
	if(distance < shake_distance):
		if(shake_camera):
			shake_camera = false
			var magnitude = 8
			player.shake_camera(magnitude)
	else:
		shake_camera = true
	

func _physics_process(delta: float) -> void:
	#if(sound_player.playing):
		#handle_camera_shake()
	if(station_timer.is_stopped()):
		if(going_east && global_position.x < east_station_x):
			if(move_step_timer.is_stopped()):
				global_position.x = global_position.x + move_step
				if(!sound_player.playing):
					sound_player.play()
				move_step_timer.start(move_timer_step)
		elif(going_east && global_position.x >= east_station_x):
			global_position.x = east_station_x
			station_timer.start(station_wait_secs)
			sound_player.stop()
			going_east = false
			returning_east = true
		elif(returning_east && global_position.x > initial_x):
			if(move_step_timer.is_stopped()):
				global_position.x = global_position.x - move_step
				if(!sound_player.playing):
					sound_player.play()
				move_step_timer.start(move_timer_step)
		elif(returning_east && global_position.x <= east_station_x):
			global_position.x = initial_x
			station_timer.start(station_wait_secs)
			sound_player.stop()
			returning_east = false
			going_west = true
		elif(going_west && global_position.x > west_station_x):
			if(move_step_timer.is_stopped()):
				global_position.x = global_position.x - move_step
				if(!sound_player.playing):
					sound_player.play()
				move_step_timer.start(move_timer_step)
		elif(going_west && global_position.x <= west_station_x):
			global_position.x = west_station_x
			station_timer.start(station_wait_secs)
			sound_player.stop()
			going_west = false
			returning_west = true
		elif(returning_west && global_position.x < initial_x):
			if(move_step_timer.is_stopped()):
				global_position.x = global_position.x + move_step
				if(!sound_player.playing):
					sound_player.play()
				move_step_timer.start(move_timer_step)
		elif(returning_west && global_position.x >= initial_x):
			global_position.x = initial_x
			station_timer.start(station_wait_secs)
			sound_player.stop()
			returning_west = false
			going_east = true
		
