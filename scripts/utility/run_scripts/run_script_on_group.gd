extends Node

@export var group : String = ""

func run_script():
	var nodes_in_group = get_tree().get_nodes_in_group(group)
	for node in nodes_in_group:
		node.run_script()
