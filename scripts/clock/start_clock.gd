extends Node

func run_script():
	var time_keeper = get_tree().get_first_node_in_group("time_keeper")
	time_keeper.unlock_time()
	var player_ref = get_tree().get_first_node_in_group("player")
	player_ref.show_hearts()
	player_ref.show_money()
	player_ref.show_dash()
	var team_manager = get_tree().get_first_node_in_group("team_manager")
	team_manager.initiate_mob_war()
	
