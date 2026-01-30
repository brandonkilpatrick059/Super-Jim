extends Node

func run_script():
	var pizza_spawner = get_tree().get_first_node_in_group("pizza_spawner")
	pizza_spawner.spawn_pizza()
	var cook_ref = get_tree().get_first_node_in_group("cook")
	cook_ref.set_schedules_index(1)
	
