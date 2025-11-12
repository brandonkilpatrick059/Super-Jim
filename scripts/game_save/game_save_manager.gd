extends Node

var save_file : FileAccess

func save_file_exists() -> bool:
	return FileAccess.file_exists("user://game_save_0.pizz")

func load_game():
	save_file = FileAccess.open("user://game_save_0.pizz", FileAccess.READ)
	load_player()
	load_time_keeper()
	while(!save_file.eof_reached()):
		var line = save_file.get_line()
		var dictionary : Dictionary = JSON.parse_string(line)
		var type = String(dictionary.get("type"))
		match type:
			"npc":
				load_npc(dictionary)
			"door":
				load_door(dictionary)
			"comment":
				load_comment(dictionary)
			"mob":
				load_mob(dictionary)
			"spawn":
				load_spawn(dictionary)
	save_file.close()

func save_game(): 
	save_file= FileAccess.open("user://game_save_0.pizz", FileAccess.WRITE)
	save_player()
	save_time_keeper()
	save_mob_war()
	save_npcs()
	save_doors()
	save_comments()
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

func load_mob(dictionary : Dictionary):
	pass

func load_spawn(dictionary : Dictionary):
	pass

func save_npcs():
	var npcs = get_tree().get_nodes_in_group("npc")
	for npc in npcs:
		var npc_dictionary : String = npc.get_save_dictionary()
		save_file.store_line(JSON.stringify(npc_dictionary))

func load_npc(dictionary : Dictionary):
	var npcs = get_tree().get_nodes_in_group("npc")
	for npc in npcs:
		var npc_tag = npc.get_save_tag()
		if(npc_tag == dictionary.get("save_tag")):
			npc.load_from_dictionary(dictionary)
		

func save_doors():
	var doors = get_tree().get_nodes_in_group("door_persistent")
	for door in doors:
		var door_dictionary : String = door.get_save_dictionary()
		save_file.store_line(JSON.stringify(door_dictionary))

func load_door(dictionary : Dictionary):
	var doors = get_tree().get_nodes_in_group("door_persistent")
	for door in doors:
		var door_tag = door.get_save_tag()
		if(door_tag == dictionary.get("save_tag")):
			door.load_from_dictionary(dictionary)

func save_comments():
	var comments = get_tree().get_nodes_in_group("comment_persistent")
	for comment in comments:
		var comment_dictionary : String = comment.get_save_dictionary()
		save_file.store_line(JSON.stringify(comment_dictionary))

func load_comment(dictionary : Dictionary):
	var comments = get_tree().get_nodes_in_group("comment_persistent")
	for comment in comments:
		var comment_tag = comment.get_save_tag()
		if(comment_tag == dictionary.get("save_tag")):
			comment.load_from_dictionary(dictionary)

func save_time_keeper():
	var time_keeper = get_tree().get_first_node_in_group("time_keeper")
	var time_keeper_dictionary : Dictionary = {
		"day_of_the_week" = time_keeper.get_day_of_week()
	}
	save_file.store_line(JSON.stringify(time_keeper_dictionary))
	
func load_time_keeper():
	var time_keeper_string = save_file.get_line() #always third line
	var time_keeper_dictionary : Dictionary = JSON.parse_string(time_keeper_string)
	var time_keeper = get_tree().get_first_node_in_group("time_keeper")
	time_keeper.set_day_of_week(int(time_keeper_dictionary.get("day_of_the_week")))
