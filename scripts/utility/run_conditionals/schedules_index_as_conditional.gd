extends Node

@export var node_group : String = ""
@export var check_keys: Array[String] = []
@export var conditional_return_map : Array[int]

func run_conditional():
	var check_node = get_tree().get_first_node_in_group(node_group)
	var current_key = check_node.get_schedules_key()
	var index = check_keys.find(current_key)
	return conditional_return_map[index]
