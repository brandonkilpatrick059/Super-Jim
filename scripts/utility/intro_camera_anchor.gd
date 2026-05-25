extends RigidBody2D

var timer : Timer = Timer.new()
var fade_out_timer : Timer = Timer.new()
var step_timer : Timer = Timer.new()
var step_timer_secs = 0.006
@export var wait_to_move_secs = 0
@export var triggered : bool = false

var secs_until_fade_out : float = 8.0

var trigger_fired = false

var player_ref = null
var camera_ref = null

var speed = 128
var current_speed = 0

var threshold_passed : bool = false

var moving = false

func fire_trigger():
	trigger_fired = true
	timer.start(wait_to_move_secs)
	fade_out_timer.start(secs_until_fade_out)

func _ready() -> void:
	timer.one_shot = true
	add_child(timer)
	step_timer.one_shot = true
	add_child(step_timer)
	fade_out_timer.one_shot = true
	add_child(fade_out_timer)
	if(!triggered):
		timer.start(wait_to_move_secs)
	camera_ref = get_tree().get_first_node_in_group("camera")
	player_ref = get_tree().get_first_node_in_group("intro_player")

func _physics_process(delta: float) -> void:
	if(trigger_fired):
		if(not moving):
			if(timer.is_stopped()):
				moving = true
				step_timer.start(step_timer_secs)
		else:
			if(step_timer.is_stopped()):
				var distance = global_position.distance_to(player_ref.global_position)
				var slow_distance = 512
				if(current_speed < speed):
					current_speed = current_speed + 4
				if(distance > slow_distance):
					current_speed = speed * (slow_distance / distance)
					if(!threshold_passed):
						camera_ref.fade_out()
						threshold_passed = true
				if(distance < slow_distance):
					linear_velocity = Vector2.UP * current_speed
				if(fade_out_timer.is_stopped()):
					var anchor_ref = get_tree().get_first_node_in_group("start_camera_anchor")
					camera_ref.connect_anchor(anchor_ref)
					camera_ref.fade_in()
					var intro_player = get_tree().get_first_node_in_group("intro_player")
					var intro_sibling = get_tree().get_first_node_in_group("intro_sibling")
					intro_player.queue_free()
					intro_sibling.queue_free()
					var real_player_ref = get_tree().get_first_node_in_group("player")
					real_player_ref.enable_collision()
					var alien = get_tree().get_first_node_in_group("dummy_alien_start")
					alien.interact()
					var time_keeper = get_tree().get_first_node_in_group("time_keeper")
					time_keeper.set_clock(13)
					queue_free()
					step_timer.start(step_timer_secs)
