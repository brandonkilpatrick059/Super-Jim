extends Node

func run_script():
	var player = get_tree().get_first_node_in_group("player")
	player.put_down_and_queue_free()
