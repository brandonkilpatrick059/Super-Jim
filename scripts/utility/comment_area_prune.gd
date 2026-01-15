extends Node

@export var node_parent : Node
@export var prune_nodes : Array[Node] = []
@export var add_to_tree : bool = false
@export var remove_from_tree : bool = false
@export var run_on_ready : bool = false

func _ready() -> void:
	run_script()

func run_script():
	if(add_to_tree):
		for node in prune_nodes:
			if(node.get_parent() != node_parent):
				node_parent.add_child(node)
	elif(remove_from_tree):
		for node in prune_nodes:
			if(node.get_parent() == node_parent):
				node_parent.remove_child(node)
