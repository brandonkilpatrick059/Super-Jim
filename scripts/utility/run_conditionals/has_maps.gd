extends Node

func run_conditional() -> bool:
	var player_ref = get_tree().get_first_node_in_group("player")
	if player_ref.get_owned_maps().size() > 0:
		return true
	else:
		return false
