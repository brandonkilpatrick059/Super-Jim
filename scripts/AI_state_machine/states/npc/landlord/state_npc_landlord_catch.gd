class_name NPC_Landlord_Catch_State
extends State

signal turn_right
signal stand(direction : String)
signal set_target(target : Node)

const turn_wait_time_secs = 2
const num_turns = 4
var current_num_turns = 0
var timer = Timer.new()

func physics_process(_delta: float):
	#check for targets
	var nodes_in_vision = ai_state_machine.get_perceptions().nodes_in_vision
	ai_state_machine.transition_to(npc_states.transit)

func _ready() -> void:
	timer.one_shot = true
	add_child(timer)

func enter(_msg := {}) -> void:
	current_num_turns = 0
	timer.start(turn_wait_time_secs)
	stand.emit("")

func exit() -> void:
	pass
