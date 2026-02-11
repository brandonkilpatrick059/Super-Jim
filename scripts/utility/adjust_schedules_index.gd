extends Node

@export var node_group : String = ""
@export var new_index : int = 0

func run_script():
	var modify_node = get_tree().get_first_node_in_group(node_group)
	modify_node.set_schedules_index(new_index)
	
func set_node_group(group : String):
	node_group = group

func set_new_index(num : int):
	new_index  = num
