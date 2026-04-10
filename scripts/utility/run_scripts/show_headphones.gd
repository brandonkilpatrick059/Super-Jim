extends Node

@export var node_group : String = ""
@export var show_headphones : bool = false

func run_script():
	var modify_node = get_tree().get_first_node_in_group(node_group)
	if(show_headphones):
		modify_node.show_headphones()
	else:
		modify_node.hide_headphones()
	
