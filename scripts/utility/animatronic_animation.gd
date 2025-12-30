extends Node

@export var animatronic_tag : String = ""

@export var animation_queue : Array[String]

func run_script():
	var animatronic = get_tree().get_first_node_in_group(animatronic_tag)
	animatronic.play_animations(animation_queue)
