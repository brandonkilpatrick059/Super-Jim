class_name NPC_State_Landlord_Look_State
extends State

signal turn_right
signal stand(direction : String) 
signal set_target(target : Node)

var current_stage_mark : Vector2

const turn_wait_time_secs = 2
var current_num_turns = 0
var timer = Timer.new()

func physics_process(_delta: float):
	#check for targets
	var nodes_in_vision = ai_state_machine.get_perceptions().nodes_in_vision
	var nodes_in_hearing = ai_state_machine.get_perceptions().nodes_in_hearing
	var player_ref = get_tree().get_first_node_in_group("player")
	var player_pos = player_ref.global_position
	var self_pos = ai_state_machine.get_perceptions().global_position
	if(player_pos.distance_to(self_pos) <= 64 &&
	!player_ref.control_is_frozen()):
		var landlord_manager = get_tree().get_first_node_in_group("landlord_manager")
		landlord_manager.catch_player()
		ai_state_machine.transition_to(npc_states.alert_passive)
		return
	#check vision
	#check nodes in vision for player
	var landlord_manager = get_tree().get_first_node_in_group("landlord_manager")
	if(!landlord_manager.get_waiting()):
		if(nodes_in_vision.size() > 0):
			for node in nodes_in_vision:
				if(node != null):
					#check for player
					if(node.is_in_group("player") && !player_ref.control_is_frozen()):
						set_target.emit(node)
						if(ai_state_machine.get_perceptions().has_line_of_sight_to_target):
							ai_state_machine.transition_to(npc_states.landlord_exclaim)
							return
	#check nodes in hearing
	#TODO: support for this
	#if(nodes_in_hearing.size() > 0):
		#ai_state_machine.transition_to(npc_states.landlord_investigate)
	#look state code
	if(timer.is_stopped()):
		if(is_instance_valid(ai_state_machine.get_perceptions().current_stage_mark)):
			var distance_to_mark = current_stage_mark.distance_to(ai_state_machine.get_perceptions().global_position)
			if(distance_to_mark < 20 && current_stage_mark == ai_state_machine.get_perceptions().current_stage_mark.global_position):
					turn_right.emit()
					timer.start(turn_wait_time_secs)
					stand.emit("") 
			else:
				if(!ai_state_machine.get_perceptions().in_dialog):
					ai_state_machine.transition_to(npc_states.landlord_transit)

func _ready() -> void:
	timer.one_shot = true
	add_child(timer)

func enter(_msg := {}) -> void:
	current_stage_mark = ai_state_machine.get_perceptions().current_stage_mark.global_position
	current_num_turns = 0
	timer.start(turn_wait_time_secs)
	stand.emit("")

func exit() -> void:
	pass
