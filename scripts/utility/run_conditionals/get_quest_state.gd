extends Node

@export var key : String = ""
@export var values : Array[String] = []

func run_conditional() -> int:
	var player_ref = get_tree().get_first_node_in_group("player")
	var state = player_ref.get_quest_state(key)
	var ret_val : int = 0
	var value_index = values.find(state)
	if(value_index >= 0):
		ret_val = value_index
	return ret_val
