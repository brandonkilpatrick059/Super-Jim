extends Node

func run_script():
	var start_camera_anchor = get_tree().get_first_node_in_group("intro_camera_anchor")
	start_camera_anchor.fire_trigger()
