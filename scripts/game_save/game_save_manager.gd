extends Node

var save_file : FileAccess

func save_file_exists() -> bool:
	return FileAccess.file_exists("user://game_save_0.pizz")

func load_game():
	save_file = FileAccess.open("user://game_save_0.pizz", FileAccess.READ)
	load_player()
	save_file.close()

func save_game(): 
	save_file= FileAccess.open("user://game_save_0.pizz", FileAccess.WRITE)
	save_player()
	save_mob_war()
	save_npcs()
	save_doors()
	save_file.close()

func save_player():
	var player_ref = get_tree().get_first_node_in_group("player")
	var player_dictionary = player_ref.get_save_dictionary()
	save_file.store_line(JSON.stringify(player_dictionary))
	var player_apartment_ref = get_tree().get_first_node_in_group("apartment_manager")
	var apartment_dictionary = player_apartment_ref.get_save_dictionary()
	save_file.store_line(JSON.stringify(apartment_dictionary))

func load_player():
	var player_string = save_file.get_line() #always first line
	var player_dictionary : Dictionary = JSON.parse_string(player_string)
	var player_ref = get_tree().get_first_node_in_group("player")
	player_ref.load_from_dictionary(player_dictionary)
	var player_apartment_string = save_file.get_line() #always second line
	var player_apartment_dictionary : Dictionary = JSON.parse_string(player_apartment_string)
	var player_apartment_ref = get_tree().get_first_node_in_group("apartment_manager")
	player_apartment_ref.load_from_dictionary(player_apartment_dictionary)
	

func save_mob_war():
	pass
	#var mobs = get_tree().get_nodes_in_group("mobster")
	#for mob in mobster:
		#var mob_dictionary = mob.get_save_dictionary()

func load_mob_war():
	pass

func save_npcs():
	pass

func load_npcs():
	pass

func save_doors():
	pass

func load_doors():
	pass
