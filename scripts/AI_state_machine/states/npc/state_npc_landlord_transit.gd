class_name NPC_Landlord_Transit_State
extends State

signal set_nav_target(pos : Vector2)
signal advance_navigation(speed : int)
signal reach_stage_mark()
signal leave_stage_mark()
signal set_target(target : Node)

var nav_target_reached = false
var host_position
var current_stage_mark : Node = null

const distance_to_break_current_point = 128

func get_host_position():
	return ai_state_machine.get_perceptions().position

func get_host_nav_target_reached():
	return ai_state_machine.get_perceptions().nav_target_reached

func physics_process(_delta: float) -> void:
	if(current_stage_mark != null):
		var nodes_in_vision = ai_state_machine.get_perceptions().nodes_in_vision
		#var nodes_in_hearing = ai_state_machine.get_perceptions().nodes_in_hearing
		nav_target_reached = get_host_nav_target_reached()
		var player_ref = get_tree().get_first_node_in_group("player")
		var player_pos = player_ref.global_position
		var self_pos = ai_state_machine.get_perceptions().global_position
		if(player_pos.distance_to(self_pos) <= 64):
			var landlord_manager = get_tree().get_first_node_in_group("landlord_manager")
			landlord_manager.catch_player()
			ai_state_machine.transition_to(npc_states.alert_passive)
			return
		if(!nav_target_reached):
			advance_navigation.emit(125000)
			#check vision
			#check nodes in vision for player
			if(nodes_in_vision.size() > 0):
				for node in nodes_in_vision:
					if(node != null):
						#check for player
						if(node.is_in_group("player")):
							set_target.emit(node)
							if(ai_state_machine.get_perceptions().has_line_of_sight_to_target):
								ai_state_machine.transition_to(npc_states.landlord_exclaim)
								return
		else:
			var stage_mark_state : String = current_stage_mark.get_state()
			#current_stage_mark = null
			ai_state_machine.transition_to(stage_mark_state)
			reach_stage_mark.emit()

func enter(_msg := {}) -> void:
	current_stage_mark = ai_state_machine.get_perceptions().current_stage_mark
	if(current_stage_mark != null):
		set_nav_target.emit(current_stage_mark.global_position)
		leave_stage_mark.emit()

func exit() -> void:
	pass
	
