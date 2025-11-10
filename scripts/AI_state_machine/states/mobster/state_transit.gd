class_name Transit_State
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
	return ai_state_machine.get_perceptions().position

func get_host_nav_target_reached():
	return ai_state_machine.get_perceptions().nav_target_reached

func physics_process(_delta: float) -> void:
		#check for targets
		var nodes_in_vision = ai_state_machine.get_perceptions().nodes_in_vision
		var nodes_in_hearing = ai_state_machine.get_perceptions().nodes_in_hearing
		#check nodes in vision for other mobs, who take priority
		var pizza = get_tree().get_first_node_in_group("pizza")
		for node in nodes_in_vision:
			if(node != null):
				if(node.is_in_group("mobster") &&
				node.is_in_group(ai_state_machine.get_perceptions().opposing_team)):
					set_target.emit(node)
					if(ai_state_machine.get_perceptions().has_line_of_sight_to_target):
						ai_state_machine.transition_to(mobster_states.exclaiming)
						return
				#check for player
				elif(node.is_in_group("courier")):
					set_target.emit(node)
					if(ai_state_machine.get_perceptions().has_line_of_sight_to_target):
						ai_state_machine.transition_to(mobster_states.exclaiming)
						return
				elif(pizza != null &&
				!ai_state_machine.perceptions.holding_object &&
				node.is_in_group("pizza") && 
				!pizza.is_picked_up()):
					set_target.emit(node)
					if(ai_state_machine.get_perceptions().reactive_has_line_of_sight_to_target):
						ai_state_machine.transition_to(mobster_states.enticed)
						return
		#check nodes in hearing
		if(nodes_in_hearing.size() > 0):
			for node in nodes_in_hearing:
				if(node.is_in_group("exclaim")):
					var source_obj = node.get_source_obj()
					if(source_obj != null):
						if(source_obj.is_in_group(ai_state_machine.get_perceptions().opposing_team)):
							set_target.emit(source_obj)
							ai_state_machine.transition_to(mobster_states.exclaiming)
							return
			ai_state_machine.transition_to(mobster_states.investigate)
		#transit code
		else:
			nav_target_reached = get_host_nav_target_reached()
			if(nav_target_reached):
				ai_state_machine.transition_to(mobster_states.look)

func distance_to_current_point() -> int:
	return get_host_position().distance_to(current_patrol_point.position)

func distance_to_position(pos: Vector2):
	return get_host_position().distance_to(pos)

func current_point_to_closest_capture_point():
	var capture_points = get_tree().get_nodes_in_group("capture_point")
	current_patrol_point = null
	for capture_point in capture_points:
		if(capture_point.is_in_group(ai_state_machine.get_perceptions().opposing_team)):
			if(current_patrol_point != null):
				var distance_to_current_point = distance_to_current_point()
				var distance_to_other_point = distance_to_position(capture_point.position)
				if(distance_to_other_point < distance_to_current_point):
					current_patrol_point = capture_point
			else:
				current_patrol_point = capture_point
	if(current_patrol_point == null):
		current_point_to_closest_point()

func current_point_to_closest_point():
	var patrol_points = get_tree().get_nodes_in_group("patrol_point")
	current_patrol_point = patrol_points[0]
	for patrol_point in patrol_points:
		var distance_to_current_point = distance_to_current_point()
		var distance_to_other_point = distance_to_position(patrol_point.position)
		if(distance_to_other_point < distance_to_current_point):
			current_patrol_point = patrol_point

func enter(_msg := {}) -> void:		
	if(ai_state_machine.get_perceptions().is_bandit):
		current_point_to_closest_capture_point()
	else:
		if(current_patrol_point == null ||
		distance_to_current_point() > distance_to_break_current_point):
			current_point_to_closest_point()
		else:
			if(current_patrol_point.has_next_point()):
				current_patrol_point = current_patrol_point.get_next_point()
	
	if(current_patrol_point != null):
		set_nav_target.emit(current_patrol_point.position)

func exit() -> void:
	pass
	#call_to_arms_timer.queue_free()
	
