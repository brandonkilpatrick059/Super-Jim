extends Node

@export var node_group = ""
@export var locked = false

func run_script():
	var modify_nodes = get_tree().get_nodes_in_group(node_group)
	for node in modify_nodes:
		if(locked):
			node.lock()
		else:
			node.unlock()
	
