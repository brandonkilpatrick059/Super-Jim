extends Node

@export var item_key : String = ""

func run_script():
	var player = get_tree().get_first_node_in_group("player")
	player.append_to_items(item_key)
