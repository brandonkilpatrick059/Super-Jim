extends Node2D

func interact():
	var player_ref = get_tree().get_first_node_in_group("player")
	player_ref.add_to_max_dash_secs(1)
	queue_free()
