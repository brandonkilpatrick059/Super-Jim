extends Node

func run_script():
	var start_tunnel_link = get_tree().get_first_node_in_group("start_tunnel_link")
	start_tunnel_link.make_inactive()
	var apartment_basement_link = get_tree().get_first_node_in_group("apartment_basement_link")
	apartment_basement_link.make_active()
