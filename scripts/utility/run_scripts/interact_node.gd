extends Node

@export var interact_node : Node
@export var stop_bypass : bool = false

func run_script():
	interact_node.interact(stop_bypass)
