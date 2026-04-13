extends Node

@export var key : String = ""
@export var value : String = ""

func run_script():
	var player_ref = get_tree().get_first_node_in_group("player")
	player_ref.set_quest_state(key,value)
