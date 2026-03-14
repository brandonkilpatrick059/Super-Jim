extends Node

func run_script():
	var pizza_ref = get_tree().get_first_node_in_group("pizza_parent")
	if(pizza_ref != null):
		pizza_ref.destroy_self()
	var cook_ref = get_tree().get_first_node_in_group("cook")
	var pizza
	var pizza_manager = get_tree().get_first_node_in_group("pizza_manager")
	if(pizza_manager.has_hit_max_daily_deliveries()):
		cook_ref.set_schedules_key("no_pizzas")
	else:
		cook_ref.set_schedules_key("delivery_dispenser")
	var courier_ref = get_tree().get_first_node_in_group("speedy")
	courier_ref.set_schedules_key("shop_tutorial")
	
