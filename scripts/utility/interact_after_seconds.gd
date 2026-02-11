extends Node

@export var interact_node : Node

var timer := Timer.new()
var can_interact = true

func _ready() -> void:
	timer.one_shot = true
	add_child(timer)
	timer.start(2.0)

func _process(delta: float) -> void:
	if(timer.is_stopped() && can_interact):
		interact_node.interact()
		can_interact = false
		queue_free()
