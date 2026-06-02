extends Node

@export var pickupable: PackedScene

func run_script():
	var player = get_tree().get_first_node_in_group("player")
	var pickup = pickupable.instantiate()
	add_child(pickup)
	player.give_pickupable(pickup)
