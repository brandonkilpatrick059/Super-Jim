extends Node

@export var script_node : Node

func _ready() -> void:
	script_node.run_script()
