extends Node

func run_script():
	var time_keeper = get_tree().get_first_node_in_group("time_keeper")
	time_keeper.unlock_time()
	var player_ref = get_tree().get_first_node_in_group("player")
	player_ref.main_ui_visible()
	var team_manager = get_tree().get_first_node_in_group("team_manager")
	team_manager.initiate_mob_war()
	
