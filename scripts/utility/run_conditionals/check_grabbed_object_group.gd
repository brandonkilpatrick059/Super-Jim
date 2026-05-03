extends Node

@export var check_group : String = ""

func run_conditional() -> int:
	var player_ref = get_tree().get_first_node_in_group("player")
	var grabbed_object : Node = player_ref.get_grabbed_object()
	var has_group : int = 0
	if(grabbed_object != null):
		for group in grabbed_object.get_groups():
			if(check_group == group):
				has_group = 1
				break
	return has_group
	
