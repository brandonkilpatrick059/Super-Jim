extends State
class_name NPC_animatronic_animation

@export var find_group : String = ""
@export var play_animation: String = ""

var played_anim = false

func physics_process(delta : float):
	if(!played_anim):
		var jeff_ref = get_tree().get_first_node_in_group(find_group)
		jeff_ref.play_animation(play_animation)
		played_anim = true

func enter(_msg := {}) -> void:
	pass

func exit() -> void:
	pass
	
