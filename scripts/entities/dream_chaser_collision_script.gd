extends Node

func run_script(body : Node):
	if(get_parent().get_ai_state() == "transit"):
		if(body.is_in_group("player")):
			body.wake_up()
			get_parent().transition_ai_state("respawn")
		if(body.is_in_group("spark")):
			get_parent().transition_ai_state("respawn")
