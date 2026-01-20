extends Node

@export var turn_on : bool = false
@export var turn_off : bool = false

func run_script():
	var player_ref = get_tree().get_first_node_in_group("player")
	if(turn_on):
		player_ref.set_checking_light_distance(true)
	elif(turn_off):
		player_ref.set_checking_light_distance(false)
