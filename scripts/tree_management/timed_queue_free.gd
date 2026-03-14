extends Node
#used by comment area prune and teleporter link

var timer := Timer.new()
#var wait_seconds : float = 2.0

var free_nodes : Array[Node] = []
var launched : bool = false

func _ready() -> void:
	timer.one_shot = true
	add_child(timer)

func set_free_nodes(nodes : Array[Node]):
	free_nodes = nodes

func launch(wait_seconds : float):
	launched = true
	timer.start(wait_seconds)

func _process(delta: float) -> void:
	if(launched && timer.is_stopped()):
		for node in free_nodes:
			if(node != null):
				node.queue_free()
		queue_free()
