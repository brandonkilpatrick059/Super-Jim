extends Node

var tutorial_mob = preload("res://entities/characters/NPC/mobsters/tutorial_mobster.tscn")

func run_script():
	var basement_door = get_tree().get_first_node_in_group("basement_door")
	basement_door.unlock()
	var tutorial_point = get_tree().get_first_node_in_group("tutorial_point")
	var dark_ysort = get_tree().get_first_node_in_group("dark_indoor_ysort")
	var mob = tutorial_mob.instantiate()
	mob.global_position = tutorial_point.global_position
	dark_ysort.add_child(mob)
