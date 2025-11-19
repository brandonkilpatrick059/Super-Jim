extends Node

func run_script():
	var modify_node = get_tree().get_first_node_in_group("cook")
	modify_node.set_schedules_index(8)
	var player_ref = get_tree().get_first_node_in_group("player")
	
