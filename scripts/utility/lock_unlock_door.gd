extends Node

@export var node_group = ""
@export var locked = false

func run_script():
	var modify_node = get_tree().get_first_node_in_group(node_group)
	if(locked):
		modify_node.lock()
	else:
		modify_node.unlock()
	
