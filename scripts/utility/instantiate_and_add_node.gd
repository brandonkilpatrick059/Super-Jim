extends Node2D

@export var node_parent : Node = null
@export var node : PackedScene = null
@export var wait_secs = 0.0
var timer := Timer.new()

var adding = false

func _ready() -> void:
	timer.one_shot = true
	add_child(timer)

func run_script():
	timer.start(wait_secs)
	adding = true

func _process(delta: float) -> void:
	if((timer.is_stopped() || wait_secs == 0.0) && adding):
		var add_node = node.instantiate()
		add_node.global_position = global_position
		node_parent.add_child(add_node)
		adding = false
