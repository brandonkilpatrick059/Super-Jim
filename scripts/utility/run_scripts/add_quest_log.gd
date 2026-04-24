extends Node

@export var quest_log_key : String = ""
@export var value : int = 0

func run_script():
	var player_node = get_tree().get_first_node_in_group("player")
	player_node.set_quest_log(quest_log_key,value)
	
