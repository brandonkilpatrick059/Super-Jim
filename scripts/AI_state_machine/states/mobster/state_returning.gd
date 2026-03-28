class_name Returning_State
extends State

var spawner_patrol_point :Node2D = null

signal set_nav_target(pos : Vector2)
signal advance_navigation
signal set_target(target : Node)
signal reduce_health()
signal drop_and_destroy_item()

var nav_target_reached = false
var setup_done = false
var host_position

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

func get_host_position():
	return ai_state_machine.get_perceptions().position

func get_host_nav_target_reached():
	return ai_state_machine.get_perceptions().nav_target_reached

func physics_process(_delta: float) -> void:
	if(handle_knockout()):
		return
	else:
		#check for targets
		var nodes_in_vision = ai_state_machine.get_perceptions().nodes_in_vision
		var nodes_in_hearing = ai_state_machine.get_perceptions().nodes_in_hearing
		for node in nodes_in_vision:
			if(node != null):
				if(node.is_in_group(ai_state_machine.get_perceptions().opposing_team) &&
				node.is_in_group("mobster")):
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
		#check hearing
		if(nodes_in_hearing.size() > 0):
			for node in nodes_in_hearing:
				if(node.is_in_group("exclaim")):
					var source_obj = node.get_source_obj()
					if(source_obj.is_in_group(ai_state_machine.get_perceptions().opposing_team)):
						set_target.emit(source_obj)
						ai_state_machine.transition_to(mobster_states.exclaiming)
						return
			ai_state_machine.transition_to(mobster_states.investigate)
		#transit code
		else:
			nav_target_reached = get_host_nav_target_reached()
			if(!nav_target_reached):
				advance_navigation.emit(125000)
			else:
				drop_and_destroy_item.emit()
				ai_state_machine.transition_to(mobster_states.look)

func distance_to_current_point() -> int:
	return get_host_position().distance_to(spawner_patrol_point.global_position)

func distance_to_position(pos: Vector2):
	return get_host_position().distance_to(pos)

func spawner_point_to_closest_point():
	if(!ai_state_machine.get_perceptions().is_tutorial):
		var patrol_points = get_tree().get_nodes_in_group("capture_point")
		spawner_patrol_point = patrol_points[0]
		for patrol_point in patrol_points:
			var distance_to_current_point = distance_to_current_point()
			var distance_to_other_point = distance_to_position(patrol_point.global_position)
			if(patrol_point.is_in_group(ai_state_machine.get_perceptions().team) &&
			distance_to_other_point < distance_to_current_point):
				spawner_patrol_point = patrol_point
	else:
		spawner_patrol_point = get_tree().get_first_node_in_group("tutorial_point")

func enter(_msg := {}) -> void:		
	spawner_point_to_closest_point()
	
	if(spawner_patrol_point != null):
		set_nav_target.emit(spawner_patrol_point.global_position)

func exit() -> void:
	pass
