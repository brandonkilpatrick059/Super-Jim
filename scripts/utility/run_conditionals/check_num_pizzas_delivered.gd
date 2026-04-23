extends Node

@export var num_pizzas_inclusive = 0
@export var exactly_equals : bool = false

func run_conditional() -> int:
	var pizza_manager = get_tree().get_first_node_in_group("pizza_manager")
	if(!exactly_equals):
		if(pizza_manager.get_total_pizzas_delivered() >= num_pizzas_inclusive):
			return 1
		else:
			return 0
	else:
		if(pizza_manager.get_total_pizzas_delivered() == num_pizzas_inclusive):
			return 1
		else:
			return 0
