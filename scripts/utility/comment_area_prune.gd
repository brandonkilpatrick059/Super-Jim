extends Node
@onready var pruner = preload("res://entities/util/prune_node.tscn")
@export var node_parent : Node
@export var prune_nodes : Array[Node] = []
@export var add_to_tree : bool = false
@export var remove_from_tree : bool = false
@export var run_on_ready : bool = false
func _ready() -> void:
	if(run_on_ready):
		run_script()

func run_script():
	if(add_to_tree):
		for node in prune_nodes:
			if(node != null && node.get_parent() != node_parent):
				node_parent.add_child(node)
	elif(remove_from_tree):
		var prune_node = pruner.instantiate()
		add_child(prune_node)
		prune_node.set_prune_nodes_and_parent(prune_nodes, node_parent)
		prune_node.launch()
