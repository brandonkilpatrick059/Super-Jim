extends Node

@export var is_sewer_entrance : bool = false
@export var is_cave_entrance : bool = false 

func run_script():
	var sewer_teleporter = get_tree().get_first_node_in_group("sewers_witch_hut_cave_link")
	var caves_teleporter = get_tree().get_first_node_in_group("caves_witch_hut_sewer_link")
	if(is_sewer_entrance):
		caves_teleporter.teleport_player() #seems backwards to me, too. I don't get it.
	elif(is_cave_entrance):
		sewer_teleporter.teleport_player()
