extends RigidBody2D

var timer : Timer = Timer.new()
var step_timer : Timer = Timer.new()
var step_timer_secs = 0.01
@export var wait_to_move_secs = 0
@export var triggered : bool = false

var trigger_fired = false

var player_ref = null
var camera_ref = null

var speed =256
var current_speed = 0

var moving = false

func fire_trigger():
	trigger_fired = true
	timer.start(wait_to_move_secs)
	var main_music_player = get_tree().get_first_node_in_group("main_music_player")
	main_music_player.change_stream("res://audio/music/sleep theme.wav",true)

func _ready() -> void:
	timer.one_shot = true
	add_child(timer)
	step_timer.one_shot = true
	add_child(step_timer)
	if(!triggered):
		timer.start(wait_to_move_secs)
	camera_ref = get_tree().get_first_node_in_group("camera")
	player_ref = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	if(trigger_fired):
		if(not moving):
			if(timer.is_stopped()):
				moving = true
				step_timer.start(step_timer_secs)
		else:
			if(step_timer.is_stopped()):
				var distance = global_position.distance_to(player_ref.global_position)
				var slow_distance = 256
				current_speed = speed
				if(distance < slow_distance):
					current_speed = speed * (distance / slow_distance)
				if(distance > 0.1):
					var vect_to_player : Vector2 = player_ref.global_position - global_position
					vect_to_player = vect_to_player.normalized()
					linear_velocity = vect_to_player * current_speed
				else:
					player_ref.connect_camera()
					player_ref.set_control_frozen(false)
					queue_free()
				step_timer.start(step_timer_secs)
