extends Node

@export var interact_group : String = ""
@export var interact_node : Node
@export var seconds : float = 2.0
@export var auto_start : bool = true
var started : bool = false
var timer := Timer.new()
var can_interact = true

func _ready() -> void:
	timer.one_shot = true
	add_child(timer)
	if(auto_start):
		timer.start(seconds)
		started = true

func run_script():
	if(!started):
		timer.start(seconds)
		started = true

func _process(delta: float) -> void:
	if(started && timer.is_stopped() && can_interact):
		if(interact_group != ""):
			var node = get_tree().get_first_node_in_group(interact_group)
			node.interact()
		elif(interact_node != null):
			interact_node.interact()
		can_interact = false
		queue_free()
