extends Node

@export var cd_key : String = ""

func run_conditional() -> int:
	var player_ref = get_tree().get_first_node_in_group("player")
	if player_ref.has_owned_cd(cd_key):
		return 1
	else:
		return 0
