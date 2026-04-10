extends Node

@export var amount : int = 0
@export var nonlethal : bool = false

func run_script():
	var player_ref = get_tree().get_first_node_in_group("player")
	player_ref.reduce_hp(amount,nonlethal)
