extends Node

var pizza = preload("res://entities/props/dynamic props/props_dynamic_pickupable/pizza/pizza.tscn")


func run_script():
	var player_ref = get_tree().get_first_node_in_group("player")
	var dark_indoor_ysort = get_tree().get_first_node_in_group("dark_indoor_ysort")
	var tutorial_pizza = pizza.instantiate()
	tutorial_pizza.set_is_tutorial(true)
	dark_indoor_ysort.add_child(tutorial_pizza)
	player_ref.return_pizza()
