class_name NPC_Landlord_Chase_State
extends State

signal set_nav_target(pos: Vector2)
signal advance_navigation(speed: int)

var nav_target_reached = false
var setup_done = false
var host_position

var chase_speed = 625000

func get_host_position():
	return ai_state_machine.get_perceptions().position

func get_host_nav_target_reached():
	return ai_state_machine.get_perceptions().nav_target_reached

func physics_process(_delta: float) -> void:
	var player_ref = get_tree().get_first_node_in_group("player")
	var player_pos = player_ref.global_position
	var self_pos = ai_state_machine.get_perceptions().global_position
	if(player_pos.distance_to(self_pos) <= 64):
		#check for frozen controls in an attempt to prevent interrupting
		#player conversations, card games, catching the player as they
		#move into a teleporter etc
		if(!player_ref.control_is_frozen()):
			var landlord_manager = get_tree().get_first_node_in_group("landlord_manager")
			landlord_manager.catch_player()
			ai_state_machine.transition_to(npc_states.alert_passive)
			return
	nav_target_reached = get_host_nav_target_reached()
	if(nav_target_reached):
		if(!ai_state_machine.get_perceptions().has_line_of_sight_to_target):
			ai_state_machine.transition_to(npc_states.landlord_look)
			return
	else:
		var last_seen_pos = ai_state_machine.get_perceptions().target_pos
		set_nav_target.emit(last_seen_pos)
		advance_navigation.emit(chase_speed)

func enter(_msg := {}) -> void:
	var last_seen_pos = ai_state_machine.get_perceptions().target_pos
	set_nav_target.emit(last_seen_pos)

func exit() -> void:
	pass
	
	
