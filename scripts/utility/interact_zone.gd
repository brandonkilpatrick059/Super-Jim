extends StaticBody2D

@export var interact_node : Node2D = null

func interact():
	if(interact_node != null):
		interact_node.interact()
