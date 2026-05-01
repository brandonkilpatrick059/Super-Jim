extends Node2D

var pizza = preload("res://entities/props/dynamic props/props_dynamic_pickupable/special/pizza/pizza.tscn")

func spawn_pizza():
	if(get_tree().get_nodes_in_group("pizza").size() != 0):
		for existing_pizza in get_tree().get_nodes_in_group("pizza"):
			existing_pizza.queue_free()
	var new_pizza = pizza.instantiate()
	get_parent().add_child(new_pizza)
	new_pizza.global_position = global_position + (Vector2(0,-16))
