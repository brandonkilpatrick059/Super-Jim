class_name Chasing_State
extends State

var current_patrol_point :Node2D = null

signal set_nav_target(pos: Vector2)
signal advance_navigation(speed: int)
signal question_bubble
signal reduce_health()
signal set_target(target : Node)

var nav_target_reached = false
var setup_done = false
var host_position

var default_speed = 625000
var bandit_speed =  700000

func get_host_position():
	return ai_state_machine.get_perceptions().position

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
		var player = get_tree().get_first_node_in_group("courier")
		var nodes_in_vision = ai_state_machine.get_perceptions().nodes_in_vision
		var nodes_in_hearing = ai_state_machine.get_perceptions().nodes_in_hearing
		for node in nodes_in_vision:
			#mobster takes priority over player
			if(ai_state_machine.get_perceptions().target_obj != null && 
			ai_state_machine.get_perceptions().target_obj.is_in_group("courier") &&
			node != null && 
			node.is_in_group("mobster") &&
			node.is_in_group(ai_state_machine.get_perceptions().opposing_team) &&
			 node != ai_state_machine.get_perceptions().target_obj &&
			!ai_state_machine.get_perceptions().has_line_of_sight_to_target):
				set_target.emit(node)
				if(ai_state_machine.get_perceptions().has_line_of_sight_to_target):
					ai_state_machine.transition_to(mobster_states.exclaiming)
					return
			elif(ai_state_machine.get_perceptions().target_obj != null &&
			!ai_state_machine.get_perceptions().target_obj.is_in_group("courier") &&
			node != null &&
			node.is_in_group("courier")):
				set_target.emit(player)
				if(ai_state_machine.get_perceptions().has_line_of_sight_to_target):
					ai_state_machine.transition_to(mobster_states.exclaiming)
					return
		
		nav_target_reached = get_host_nav_target_reached()
		if(nav_target_reached):
			if(!ai_state_machine.get_perceptions().has_line_of_sight_to_target):
				if(randf_range(0.0,1.0) < 0.5): #lose a coin toss and they've got a bead on you
					ai_state_machine.transition_to(mobster_states.chasing)
				else: #win a coin toss and they haven't a clue
					ai_state_machine.transition_to(mobster_states.look)
				return
			else:
				ai_state_machine.transition_to(mobster_states.strafing)

func enter(_msg := {}) -> void:
	if(ai_state_machine.get_perceptions().target_obj != null):
		var last_seen_pos = ai_state_machine.get_perceptions().target_obj.global_position
		set_nav_target.emit(last_seen_pos)
	else:
		var last_seen_pos = ai_state_machine.get_perceptions().target_pos
		set_nav_target.emit(last_seen_pos)

func exit() -> void:
	pass
	
