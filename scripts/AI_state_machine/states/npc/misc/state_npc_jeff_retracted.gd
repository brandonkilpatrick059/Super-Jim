extends State
class_name NPC_jeff_retracted

var played_anim = false

func physics_process(delta : float):
	if(!played_anim):
		var jeff_ref = get_tree().get_first_node_in_group("jeff")
		jeff_ref.play_animation("retracted")
		played_anim = true

func enter(_msg := {}) -> void:
	pass

func exit() -> void:
	pass
	
