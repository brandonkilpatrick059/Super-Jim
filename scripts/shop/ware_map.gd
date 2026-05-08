extends Node

@export var map_string = ""

func run_script():
	var player_ref = get_tree().get_first_node_in_group("player")
	player_ref.add_owned_map(map_string)
