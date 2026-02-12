extends Node

func run_conditional() -> int:
	var pizza_manager = get_tree().get_first_node_in_group("pizza_manager")
	if(pizza_manager.has_hit_max_daily_deliveries()):
		return 1
	else:
		return 0
