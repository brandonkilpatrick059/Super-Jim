extends Node

@export var light_tag : String = ""

@export var fade_in : bool = false
@export var fade_out : bool = false

func run_script():
	var light = get_tree().get_first_node_in_group(light_tag)
	if(fade_in):
		light.fade_in()
	elif(fade_out):
		light.fade_out()
