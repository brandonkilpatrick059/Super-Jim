extends Node

@export var script_node : Node
@export var seconds : float = 2.0
var timer := Timer.new()
var can_interact = true

func _ready() -> void:
	timer.one_shot = true
	add_child(timer)
	timer.start(seconds)

func _process(delta: float) -> void:
	if(timer.is_stopped() && can_interact):
		script_node.run_script()
		can_interact = false
		queue_free()
