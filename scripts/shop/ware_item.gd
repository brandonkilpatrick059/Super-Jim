extends Node

@export var item_string = ""
@export var removes_item_string = ""

func run_script():
	var player_ref = get_tree().get_first_node_in_group("player")
	player_ref.append_to_items(item_string)
	if(removes_item_string != ""):
		player_ref.remove_from_items(removes_item_string)
