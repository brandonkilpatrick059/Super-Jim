extends Node

@export var script_nodes : Array[Node] = []
@export var conditional_node : Node = null
@export var reverse_conditional : bool = false

func run_script():
	var can_run = true
	if(conditional_node != null):
		can_run = conditional_node.run_conditional()
		if(reverse_conditional):
			can_run = ! can_run
	if(can_run):
		for node in script_nodes:
			node.run_script()
