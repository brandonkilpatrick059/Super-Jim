extends Node

var save_file : FileAccess
var mobster = preload("res://entities/characters/NPC/mobsters/mobster.tscn")
var mobster_parent : Node

func save_file_exists() -> bool:
	return FileAccess.file_exists("user://game_save_0.pizz")

func load_game():
	mobster_parent = get_tree().get_first_node_in_group("daylight_affected_ysort")
	save_file = FileAccess.open("user://game_save_0.pizz", FileAccess.READ)
	load_player()
	load_time_keeper()
	load_pizza_manager()
	while(save_file.get_position() < save_file.get_length()):
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
			"crystal":
				load_crystal(dictionary)
			"cash":
				load_cash(dictionary)
			"tip_trigger":
				load_trigger(dictionary)
	save_file.close()
	handle_queue_free_on_load()



func handle_queue_free_on_load():
	var nodes = get_tree().get_nodes_in_group("queue_free_on_load")
	for node in nodes:
		node.queue_free()

func save_game(): 
	save_file= FileAccess.open("user://game_save_0.pizz", FileAccess.WRITE)
	save_player()
	save_time_keeper()
	save_pizza_manager()
	save_mob_war()
	save_npcs()
	save_doors()
	save_comments()
	save_crystals()
	save_cash()
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
	var mobs = get_tree().get_nodes_in_group("mobster")
	for mob in mobs:
		if(!mob.get_is_tutorial()):
			var mob_dictionary = mob.get_save_dictionary()
			save_file.store_line(JSON.stringify(mob_dictionary))
	var spawners = get_tree().get_nodes_in_group("capture_point")
	for spawner in spawners:
		var spawn_dictionary = spawner.get_save_dictionary()
		save_file.store_line(JSON.stringify(spawn_dictionary))

func load_mob(dictionary : Dictionary):
	var mob = mobster.instantiate()
	mobster_parent.add_child(mob)
	mob.load_from_dictionary(dictionary)
	mob.initialize_mob()

func load_spawn(dictionary : Dictionary):
	var spawns = get_tree().get_nodes_in_group("capture_point")
	for spawn in spawns:
		if (spawn.get_save_tag() != ""):
			var spawn_tag = spawn.get_save_tag()
			if(spawn_tag == dictionary.get("save_tag")):
				spawn.load_from_dictionary(dictionary)

func save_npcs():
	var npcs = get_tree().get_nodes_in_group("npc")
	for npc in npcs:
		if (npc.get_save_tag() != ""):
			var npc_dictionary : Dictionary = npc.get_save_dictionary()
			save_file.store_line(JSON.stringify(npc_dictionary))

func load_npc(dictionary : Dictionary):
	var npcs = get_tree().get_nodes_in_group("npc")
	for npc in npcs:
		if(npc.get_save_tag() != ""):
			var npc_tag = npc.get_save_tag()
			if(npc_tag == dictionary.get("save_tag")):
				npc.load_from_dictionary(dictionary)

func save_crystals():
	var crystals = get_tree().get_nodes_in_group("dash_crystal")
	for crystal in crystals:
		var crystal_dictionary : Dictionary = crystal.get_save_dictionary()
		save_file.store_line(JSON.stringify(crystal_dictionary))

func load_crystal(dictionary : Dictionary):
	var crystals = get_tree().get_nodes_in_group("dash_crystal")
	for crystal in crystals:
		var crystal_tag = crystal.get_save_tag()
		if(crystal_tag == dictionary.get("save_tag")):
			crystal.load_from_dictionary(dictionary)

func save_cash():
	var cash_pickups = get_tree().get_nodes_in_group("cash")
	for cash in cash_pickups:
		var cash_dictionary : Dictionary = cash.get_save_dictionary()
		save_file.store_line(JSON.stringify(cash_dictionary))

func load_cash(dictionary : Dictionary):
	var cash_pickups = get_tree().get_nodes_in_group("cash")
	for cash in cash_pickups:
		var cash_tag = cash.get_save_tag()
		if(cash_tag == dictionary.get("save_tag")):
			cash.load_from_dictionary(dictionary)

func save_doors():
	var doors = get_tree().get_nodes_in_group("door_persistent")
	for door in doors:
		var door_dictionary : Dictionary = door.get_save_dictionary()
		save_file.store_line(JSON.stringify(door_dictionary))

func load_door(dictionary : Dictionary):
	var doors = get_tree().get_nodes_in_group("door_persistent")
	for door in doors:
		var door_tag = door.get_save_tag()
		if(door_tag == dictionary.get("save_tag")):
			door.load_from_dictionary(dictionary)

func save_tip_triggers():
	var triggers = get_tree().get_nodes_in_group("tip_trigger_persistent")
	for trigger in triggers:
		var trigger_dictionary : Dictionary = trigger.get_save_dictionary()
		save_file.store_line(JSON.stringify(trigger_dictionary))

func load_trigger(dictionary : Dictionary):
	var triggers = get_tree().get_nodes_in_group("tip_trigger_persistent")
	for trigger in triggers:
		var trigger_tag = trigger.get_save_tag()
		if(trigger_tag == dictionary.get("save_tag")):
			trigger.load_from_dictionary(dictionary)

func save_comments():
	var comments = get_tree().get_nodes_in_group("comment_persistent")
	for comment in comments:
		var comment_dictionary : Dictionary = comment.get_save_dictionary()
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
		"day_of_the_week" = time_keeper.get_day_of_week(),
		"days_passed" = time_keeper.get_days_passed(),
		"hour" = time_keeper.get_hour(),
		"day_of_moon_cycle" = time_keeper.get_day_of_moon_cycle()
	}
	save_file.store_line(JSON.stringify(time_keeper_dictionary))
	
func load_time_keeper():
	var time_keeper_string = save_file.get_line() #always third line
	var time_keeper_dictionary : Dictionary = JSON.parse_string(time_keeper_string)
	var time_keeper = get_tree().get_first_node_in_group("time_keeper")
	time_keeper.set_day_of_week(int(time_keeper_dictionary.get("day_of_the_week")))
	time_keeper.set_days_passed(int(time_keeper_dictionary.get("days_passed")))
	time_keeper.set_clock(int(time_keeper_dictionary.get("hour")))
	time_keeper.set_day_of_moon_cycle(int(time_keeper_dictionary.get("day_of_moon_cycle")))

func save_pizza_manager():
	var pizza_manager = get_tree().get_first_node_in_group("pizza_manager")
	var pizza_manager_dictionary : Dictionary = {
		"level" = pizza_manager.get_level(),
		"total_pizzas_delivered" = pizza_manager.get_total_pizzas_delivered(),
		"has_delivered_max_pizzas" = pizza_manager.has_hit_max_daily_deliveries(),
		"is_leaving_tutorial" = pizza_manager.get_is_leaving_tutorial()
	}
	save_file.store_line(JSON.stringify(pizza_manager_dictionary))
	
func load_pizza_manager():
	var pizza_manager_string = save_file.get_line() #always fourth line
	var pizza_manager_dictionary : Dictionary = JSON.parse_string(pizza_manager_string)
	var pizza_manager = get_tree().get_first_node_in_group("pizza_manager")
	pizza_manager.set_level(int(pizza_manager_dictionary.get("level")))
	pizza_manager.set_total_pizzas_delivered(int(pizza_manager_dictionary.get("total_pizzas_delivered")))
	pizza_manager.set_level(int(pizza_manager_dictionary.get("level")))
	pizza_manager.set_has_delivered_max_pizzas(pizza_manager_dictionary.get("has_delivered_max_pizzas"))
	pizza_manager.set_is_leaving_tutorial(pizza_manager_dictionary.get("is_leaving_tutorial"))

func save_settings():
	#user settings
	var settings : Dictionary = get_settings_dictionary()
	var settings_file : FileAccess = FileAccess.open("user://settings.save", FileAccess.WRITE)
	settings_file.store_line(JSON.stringify(settings))
	
	#input map settings
	var input_map_manager = get_tree().get_first_node_in_group("input_map_manager")
	var current_mapping = input_map_manager.get_current_mapping()
	var keyboard_dictionary : Dictionary = current_mapping.get_keyboard_dictionary()
	var controller_dictionary : Dictionary = current_mapping.get_controller_dictionary()
	settings_file.store_line(JSON.stringify(keyboard_dictionary))
	settings_file.store_line(JSON.stringify(controller_dictionary))
	
	settings_file.close()

func get_settings_dictionary() -> Dictionary:
	var settings_dictionary = {
		"lighting_index" = SettingsVariables.lighting_index,
		"resolution_index" = SettingsVariables.resolution_index,
		"full_screen" = SettingsVariables.full_screen
	}
	return settings_dictionary
