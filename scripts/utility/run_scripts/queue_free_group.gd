extends Node

@export var group_name : String

func run_script():
	var group_nodes : Array[Node] = get_tree().get_nodes_in_group(group_name)
	for node in group_nodes:
		node.queue_free()
	
