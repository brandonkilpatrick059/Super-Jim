extends Node

@export var map : String = ""

func run_script():
	var player = get_tree().get_first_node_in_group("player")
	player.add_owned_map(map)
