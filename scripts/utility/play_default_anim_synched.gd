@tool

extends Node2D

@export var speed_factor : float = 1.0

var started_anims = false

func _process(delta: float) -> void:
	if(!started_anims):
		var children = get_children()
		for child in children:
			var animation_name = "default"
			child.play(animation_name, speed_factor)
		for child in children:
			child.frame = 0
		started_anims = true
	
