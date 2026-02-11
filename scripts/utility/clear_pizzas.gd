extends Node

func run_script():
	var pizza_ref = get_tree().get_first_node_in_group("pizza_parent")
	if(pizza_ref != null):
		pizza_ref.destroy_self()
	var cook_ref = get_tree().get_first_node_in_group("cook")
	var pizza
	cook_ref.set_schedules_index(0)
	var pizza_manager = get_tree().get_first_node_in_group("pizza_manager")
	if(pizza_manager.has_hit_max_daily_deliveries()):
		cook_ref.set_schedules_index(9)
		pizza_manager.restock_pizzas_at_end_of_day()
	else:
		cook_ref.set_schedules_index(0)
	
