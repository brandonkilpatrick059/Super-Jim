extends Node

@export var script_node : Node

func run_script():
	remove_child(script_node)
	var time_keeper = get_tree().get_first_node_in_group("time_keeper")
	time_keeper.add_end_of_day_script_node(script_node)
