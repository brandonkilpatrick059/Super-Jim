extends Node

func run_script():
	var player_ref = get_tree().get_first_node_in_group("player")
	player_ref.add_fire_crackers(3)
	var sound_player = get_tree().get_first_node_in_group("main_fx_player")
	sound_player.stream = load("res://audio/soundFX/dash_regen.wav")
	sound_player.play()
