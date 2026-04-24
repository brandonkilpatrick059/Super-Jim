extends Node


func run_script():
	var player_ref = get_tree().get_first_node_in_group("player")
	player_ref.give_dash_seconds(player_ref.get_max_dash_secs())
	player_ref.main_ui_visible()
	var team_manager = get_tree().get_first_node_in_group("team_manager")
	team_manager.initiate_mob_war()
	player_ref.set_quest_log("start_door",0)
