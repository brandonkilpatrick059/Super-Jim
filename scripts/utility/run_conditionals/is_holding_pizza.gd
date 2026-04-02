extends Node

func run_conditional() -> bool:
	var player_ref = get_tree().get_first_node_in_group("player")
	if player_ref.is_in_group("courier"):
		return true
	else:
		return false
