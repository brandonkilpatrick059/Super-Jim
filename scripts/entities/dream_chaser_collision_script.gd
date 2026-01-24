extends Node

func run_script(body : Node):
	if(get_parent().get_ai_state() == "transit"):
		#var spawn = get_tree().get_first_node_in_group("dream_chaser_spawn")
		#if(get_parent().global_position.distance_to(spawn.global_position) < 200):
			#body.return_to_home()
		if(body.is_in_group("player")):
			body.wake_up()
		get_parent().transition_ai_state("respawn")
