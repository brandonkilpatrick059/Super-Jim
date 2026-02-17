extends Node
#used by comment area prune

var timer := Timer.new()
#var wait_seconds : float = 2.0

var prune_nodes : Array[Node] = []
var node_parent : Node
var launched : bool = false

func _ready() -> void:
	timer.one_shot = true
	add_child(timer)

func set_prune_nodes_and_parent(nodes : Array[Node], parent : Node):
	prune_nodes = nodes
	node_parent = parent

func launch(wait_seconds : float):
	launched = true
	timer.start(wait_seconds)

func _process(delta: float) -> void:
	if(launched && timer.is_stopped()):
		for node in prune_nodes:
			if(node.get_parent() == node_parent):
				node_parent.remove_child(node)
		queue_free()
