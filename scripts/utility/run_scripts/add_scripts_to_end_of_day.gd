extends Node

@export var script_nodes : Array[Node] = []

func run_script():
	var time_keeper = get_tree().get_first_node_in_group("time_keeper")
	for script in script_nodes:
		var add_script = script.duplicate()
		time_keeper.add_end_of_day_script_node(add_script)
