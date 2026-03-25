class_name Courier_Transit_State
extends State

var current_patrol_point :Node2D = null

signal set_nav_target(pos : Vector2)
signal advance_navigation
signal set_target(target : Node)
signal reduce_health()
signal call_to_arms()

var nav_target_reached = false
var host_position

const distance_to_break_current_point = 128

var call_to_arms_timer : Timer
var call_to_arms_freq_secs = 45

func get_host_position():
	return ai_state_machine.get_perceptions().global_position

func get_host_nav_target_reached():
	return ai_state_machine.get_perceptions().nav_target_reached

func handle_knockout() -> bool:
	#knockout when player throws object
	for node in ai_state_machine.get_perceptions().colliding_nodes:
			if(node != null &&
				!ai_state_machine.get_perceptions().invincible &&
				node.is_in_group("spark") &&
				!node.is_in_group("red") &&
				!node.is_in_group("blu")):
				ai_state_machine.transition_to(mobster_states.falling)
				return true
	return false

func physics_process(_delta: float) -> void:
	if(handle_knockout()):
		return
	else:
		#transit code
		nav_target_reached = get_host_nav_target_reached()
		if(nav_target_reached):
			ai_state_machine.transition_to(mobster_states.courier_transit)

func distance_to_current_point() -> int:
	return get_host_position().distance_to(current_patrol_point.global_position)

func distance_to_position(pos: Vector2):
	return get_host_position().distance_to(pos)

func current_point_to_closest_point():
	var patrol_points = get_tree().get_nodes_in_group("patrol_point")
	current_patrol_point = patrol_points[0]
	for patrol_point in patrol_points:
		var distance_to_current_point = distance_to_current_point()
		var distance_to_other_point = distance_to_position(patrol_point.global_position)
		if(distance_to_other_point < distance_to_current_point):
			current_patrol_point = patrol_point

func enter(_msg := {}) -> void:		
	if(current_patrol_point == null ||
	distance_to_current_point() > distance_to_break_current_point):
		current_point_to_closest_point()
	else:
		if(current_patrol_point.has_next_point()):
			current_patrol_point = current_patrol_point.get_next_point()
	
	if(current_patrol_point != null):
		set_nav_target.emit(current_patrol_point.global_position)

func exit() -> void:
	pass
	#call_to_arms_timer.queue_free()
	
