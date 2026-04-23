extends Node

@export var key : String = ""
@export var value : int = 0

func run_script():
	var player = get_tree().get_first_node_in_group("player")
	player.sew_quest_log(key,value)
