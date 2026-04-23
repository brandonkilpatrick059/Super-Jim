extends Node

@export var node_group : String = ""
@export var check_key: String = ""

func run_conditional():
	var check_node = get_tree().get_first_node_in_group(node_group)
	if(check_node.get_schedules_key() == check_key):
		return 1
	else:
		return 0
