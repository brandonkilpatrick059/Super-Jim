extends Node

@export var node_group = ""
@export var new_index = 0

func run_script():
	var modify_node = get_tree().get_first_node_in_group(node_group)
	modify_node.set_schedules_index(new_index)
	
