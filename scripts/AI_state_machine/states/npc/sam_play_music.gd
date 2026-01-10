class_name NPC_Sam_Play_Music
extends State

signal play_sound(path : String)
signal play_animation(name : String)
signal stop_sound()
signal immobilize(input : bool)

var current_stage_mark : Vector2

var sound_playing : bool = false

func physics_process(_delta: float) -> void:
	if(is_instance_valid(ai_state_machine.get_perceptions().current_stage_mark)):
		if(current_stage_mark == ai_state_machine.get_perceptions().current_stage_mark.global_position):
				if(!sound_playing):
					sound_playing = true
					play_sound.emit("res://audio/music/sam_music.wav")
				play_animation.emit("play_music")
		else:
			if(!ai_state_machine.get_perceptions().in_dialog):
				ai_state_machine.transition_to(npc_states.transit)


func enter(_msg := {}) -> void:
	immobilize.emit(true)
	current_stage_mark = ai_state_machine.get_perceptions().current_stage_mark.global_position

func exit():
	sound_playing = false
	immobilize.emit(false)
	stop_sound.emit()
