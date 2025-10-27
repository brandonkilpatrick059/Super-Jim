extends Node2D

func interact():
	var player_ref = get_tree().get_first_node_in_group("player")
	player_ref.add_to_max_dash_secs(1)
	player_ref.regen_dash_secs(player_ref.get_max_dash_secs())
	queue_free()
