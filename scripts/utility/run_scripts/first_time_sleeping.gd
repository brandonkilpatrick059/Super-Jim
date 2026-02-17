extends Node

func run_script():
	var modify_node = get_tree().get_first_node_in_group("cook")
	modify_node.set_schedules_index(7)
	var player_ref = get_tree().get_first_node_in_group("player")
	var time_keeper = get_tree().get_first_node_in_group("time_keeper")
	time_keeper.unlock_time()
	
