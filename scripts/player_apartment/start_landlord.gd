extends Node

func run_script():
	var landlord_manager = get_tree().get_first_node_in_group("landlord_manager")
	landlord_manager.landlord_start()
	var time_keeper = get_tree().get_first_node_in_group("time_keeper")
	time_keeper.unlock_time()
