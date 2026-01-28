extends Node

func run_script():
	var pizza_ref = get_tree().get_first_node_in_group("pizza_parent")
	if(pizza_ref != null):
		pizza_ref.destroy_self()
	var cook_ref = get_tree().get_first_node_in_group("cook")
	cook_ref.set_schedules_index(0)
	
