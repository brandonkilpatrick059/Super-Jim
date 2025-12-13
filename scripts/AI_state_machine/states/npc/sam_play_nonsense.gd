class_name NPC_Sam_Play_Nonsense
extends State

signal play_sound(path : String)
signal play_animation(name : String)
signal stop_sound()
signal immobilize(input : bool)

var current_stage_mark : Vector2

var sound_playing : bool = false

var attenuation_distance = 200

func physics_process(_delta: float) -> void:
	if(is_instance_valid(ai_state_machine.get_perceptions().current_stage_mark)):
		
		var player_ref = get_tree().get_first_node_in_group("player")
		var distance = player_ref.global_position.distance_to(ai_state_machine.get_perceptions().global_position)
		var music_player = get_tree().get_first_node_in_group("main_music_player")
		if(distance < attenuation_distance):
			var volume = -((attenuation_distance - distance)/10)
			music_player.set_volume(volume)
		if(current_stage_mark == ai_state_machine.get_perceptions().current_stage_mark.global_position):
				if(!sound_playing):
					sound_playing = true
					play_sound.emit("res://audio/music/nonsense.wav")
					play_animation.emit("play_music")
		else:
			if(!ai_state_machine.get_perceptions().in_dialog):
				ai_state_machine.transition_to(npc_states.transit)


func enter(_msg := {}) -> void:
	immobilize.emit(true)
	current_stage_mark = ai_state_machine.get_perceptions().current_stage_mark.global_position

func exit():
	var music_player = get_tree().get_first_node_in_group("main_music_player")
	music_player.set_volume(0)
	sound_playing = false
	immobilize.emit(false)
	stop_sound.emit()
