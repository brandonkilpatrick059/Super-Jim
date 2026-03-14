extends Node2D

var free_node = preload("res://entities/util/free_node.tscn")

func run_script():
	var pizza = get_tree().get_first_node_in_group("pizza")
	if(pizza != null && !pizza.is_picked_up()):
		pizza.queue_free()
	var tutorial_mob = get_tree().get_first_node_in_group("fake_mob")
	if(tutorial_mob != null):
		var free_n = free_node.instantiate()
		var tutorial_mob_array : Array[Node] = [tutorial_mob]
		free_n.set_free_nodes(tutorial_mob_array)
		add_child(free_n)
		free_n.launch(2.0)
