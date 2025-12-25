extends Node

func run_script():
	var apartment_manager = get_tree().get_first_node_in_group("apartment_manager")
	apartment_manager.add_tv()
