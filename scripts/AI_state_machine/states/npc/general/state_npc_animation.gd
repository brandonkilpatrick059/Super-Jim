class_name NPC_Play_Animation
extends State

@export var animation_name : String = ""

var wait_timer := Timer.new()
var waiting_to_transit = false

func _ready():
	wait_timer.one_shot = true
	add_child(wait_timer)

func physics_process(_delta: float) -> void:
	if(is_instance_valid(ai_state_machine.get_perceptions().current_stage_mark)):
		if(ai_state_machine.get_perceptions().global_position == ai_state_machine.get_perceptions().current_stage_mark.global_position):
				get_parent().get_parent().play_animation(animation_name)
		else:
			if(not waiting_to_transit):
				waiting_to_transit = true
				var wait_time = ai_state_machine.get_perceptions().current_stage_mark.get_wait_time()
				var rand_wait = randf_range(0.0, wait_time)
				wait_timer.start(rand_wait)
				get_parent().get_parent().play_animation(animation_name)
			else:
				if(wait_timer.is_stopped()):
					if(!ai_state_machine.get_perceptions().in_dialog):
						ai_state_machine.transition_to(npc_states.transit)
				else:
					get_parent().get_parent().play_animation(animation_name)

func enter(_msg := {}) -> void:
	waiting_to_transit = false

func exit() -> void:
	pass
