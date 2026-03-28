class_name Enticed_State
extends State

signal set_nav_target(pos : Vector2)
signal advance_navigation
signal set_target(target : Node)
signal pick_up(node: Node)
signal reduce_health()
signal pizza_bubble()
signal stop_movement()

var nav_target_reached = false
var host_position
var pizza_ref : Node = null

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
		#check for targets
		var player = get_tree().get_first_node_in_group("courier")
		var nodes_in_vision = ai_state_machine.get_perceptions().nodes_in_vision
		var nodes_in_hearing = ai_state_machine.get_perceptions().nodes_in_hearing
		for node in nodes_in_vision:
			if(node != null):
				if(node.is_in_group(ai_state_machine.get_perceptions().opposing_team) &&
					node.is_in_group("mobster") || node.is_in_group("courier")):
						set_target.emit(node)
						if(ai_state_machine.get_perceptions().has_line_of_sight_to_target):
							ai_state_machine.transition_to(mobster_states.exclaiming)
							return
		if(nodes_in_hearing.size() > 0):
			for node in nodes_in_hearing:
				if(node.is_in_group("exclaim")):
					var source_obj = node.get_source_obj()
					if(source_obj.is_in_group(ai_state_machine.get_perceptions().opposing_team)):
						set_target.emit(source_obj)
						ai_state_machine.transition_to(mobster_states.exclaiming)
						return
		#enticed code
		else:
			var player_ref = get_tree().get_first_node_in_group("player")
			if(pizza_ref != null):
				var player_distance_to_pizza = player_ref.global_position.distance_to(pizza_ref.global_position)
				if(player_distance_to_pizza < 16):
					set_target.emit(player_ref)
					ai_state_machine.transition_to(mobster_states.exclaiming)
				elif(!pizza_ref.is_picked_up() && 
				ai_state_machine.perceptions.reactive_has_line_of_sight_to_target):
					nav_target_reached = get_host_nav_target_reached()
					var global_pos = ai_state_machine.get_perceptions().global_position
					var distance_to_pizza = global_pos.distance_to(pizza_ref.global_position)
					if(nav_target_reached && distance_to_pizza < 96):
						if(!pizza_ref.is_picked_up()):
							pick_up.emit(pizza_ref)
							stop_movement.emit()
							ai_state_machine.transition_to(mobster_states.returning) 
						else: #picked up by another mob
							stop_movement.emit()
							ai_state_machine.transition_to(mobster_states.look)
					elif(nav_target_reached):
						set_nav_target.emit(pizza_ref.global_position)
				else:
					stop_movement.emit()
					ai_state_machine.transition_to(mobster_states.look)
			else:
				stop_movement.emit()
				ai_state_machine.transition_to(mobster_states.look)

func enter(_msg := {}) -> void:
	pizza_bubble.emit()
	pizza_ref = get_tree().get_first_node_in_group("pizza")
	set_nav_target.emit(pizza_ref.global_position)
	set_target.emit(pizza_ref)

func exit() -> void:
	pass
	
