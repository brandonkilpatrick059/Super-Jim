extends Node

@export var group1 : String = ""
@export var group2 : String = ""
@export var less_than_distance : float = 100

func run_conditional() -> int:
	var g1_ref : Node2D = get_tree().get_first_node_in_group(group1)
	var g2_ref : Node2D = get_tree().get_first_node_in_group(group2)
	if(g1_ref != null && g2_ref != null):
		var distance = g1_ref.global_position.distance_to(g2_ref.global_position)
		if(distance < less_than_distance):
			return 1
		else:
			return 0
	else: 
		return 0
