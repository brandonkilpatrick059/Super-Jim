extends Node

@export var cd_key : String = ""

func run_script():
	var player_ref = get_tree().get_first_node_in_group("player")
	player_ref.remove_owned_cd(cd_key)
