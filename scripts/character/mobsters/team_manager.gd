extends Node2D

var red_spawners : Array[Node] = []
var blu_spawners : Array[Node] = []

var spawn_timer_len_secs = 5

var spawn_timer : Timer = Timer.new()

var num_mobs_to_spawn = 3

var spawns_locked = true

var total_prune_nodes : int = 0

func _ready() -> void:
	spawn_timer.one_shot = true
	add_child(spawn_timer)
	total_prune_nodes = get_tree().get_nodes_in_group("prunable").size()

func initiate_mob_war():
	#randomize spawner allegiance roughly down the middle,
	#favoring red team
	var spawners = get_tree().get_nodes_in_group("capture_point")
	var num_blue_spawners = spawners.size() / 2
	while(num_blue_spawners > 0):
		var index = randi_range(0,spawners.size()-1)
		var spawn = spawners[index]
		spawn.set_team("blu")
		blu_spawners.append(spawn)
		spawners.remove_at(index)
		num_blue_spawners = num_blue_spawners - 1
	red_spawners = spawners
	spawns_locked = false
	spawn_timer.start(spawn_timer_len_secs)

func unlock_spawns():
	spawns_locked = false

func get_and_unlock_spawns():
	get_spawner_lists()
	unlock_spawns()

func get_spawner_lists():
	var capture_points = get_tree().get_nodes_in_group("capture_point")
	for point in capture_points:
		if(point.get_team() == "blu"):
			blu_spawners.append(point)
		elif(point.get_team() == "red"):
			red_spawners.append(point)

func spawn_mobs():
	var temp_blu_spawners = blu_spawners.duplicate()
	var temp_red_spawners = red_spawners.duplicate()
	var num_red_mobs = 0
	var num_blu_mobs = 0
	var num_red_bandits = 0
	var num_blu_bandits = 0
	var num_red_points = 0
	var num_blu_points = 0
	var current_mobs = get_tree().get_nodes_in_group("mobster")
	var points = get_tree().get_nodes_in_group("capture_point")
	for point in points:
		if(point.is_in_group("red")):
			num_red_points = num_red_points + 1
		elif(point.is_in_group("blu")):
			num_blu_points = num_blu_points + 1
	for mob in current_mobs:
		if(mob.is_in_group("red")):
			num_red_mobs = num_red_mobs + 1
			if(mob.is_in_group("bandit")):
				num_red_bandits = num_red_bandits + 1
		elif(mob.is_in_group("blu")):
			num_blu_mobs = num_blu_mobs + 1
			if(mob.is_in_group("bandit")):
				num_blu_bandits = num_blu_bandits + 1
	#you may ask yourself
	#"what made me put these logs here?"
	#you may ask yourself
	#"where should I move this code to?"
	#and you may ask yourself
	#"am I right, am I wrong?"
	#And you may say to yourself
	#"My God, what have I done?"
	var iter = 0
	print("===================================")
	print("FRAME: ",Engine.get_frames_drawn())
	var pizza_manager = get_tree().get_first_node_in_group("pizza_manager")
	print("=========PROGRESS==========")
	print(str("LEVEL:  "), pizza_manager.get_level())
	print(str("Pizzas: "), pizza_manager.get_total_pizzas_delivered())
	print("==========MOB WAR==========")
	print(str("Total Mobs-----", current_mobs.size()))
	print(str("Total Bandits:-", num_red_bandits + num_blu_bandits))
	print(str("BLU:-----------", num_blu_points))
	print(str("Blu Mobs:------", num_blu_mobs))
	print(str("+Bandits:------", num_blu_bandits))
	print(str("+Goons:--------", num_blu_mobs - num_blu_bandits))
	print(str("RED:-----------", num_red_points))
	print(str("Red Mobs:------", num_red_mobs))
	print(str("+Bandits:------", num_red_bandits))
	print(str("+Goons:--------", num_red_mobs - num_red_bandits))
	var num_bullets = get_tree().get_nodes_in_group("bullet")
	print(str("# BULLETS: ",num_bullets.size()))
	var num_nodes = get_tree().get_node_count()
	print("==========PERFORMANCE==========")
	print(str("# TOTAL NODES: "), num_nodes)
	var prune_nodes = get_tree().get_nodes_in_group("prunable")
	print(str("+prunable total:---"), total_prune_nodes)
	print(str("+prunable loaded:--"), prune_nodes.size())
	print(str("FRAMERATE: ",Engine.get_frames_per_second()))
	#var num_teles = get_tree().get_nodes_in_group("teleporter")
	#print(str("# teleporters: ",num_teles.size()))
	while(iter < num_mobs_to_spawn):
		var red_spawner = get_loneliest_spawner(temp_red_spawners)
		var blu_spawner = get_loneliest_spawner(temp_blu_spawners)
		if(red_spawner != null):
			red_spawner.spawn_mob()
			if(temp_red_spawners.size() > 1):
				temp_red_spawners.remove_at(temp_red_spawners.find(red_spawner))
		if(blu_spawner != null):
			blu_spawner.spawn_mob()
			if(temp_blu_spawners.size() > 1):
				temp_blu_spawners.remove_at(temp_blu_spawners.find(blu_spawner))
		iter = iter + 1

func get_loneliest_spawner(spawners : Array[Node]):
	if(spawners.size() > 0):
		var lonely_spawner = spawners[0]
		for spawner in spawners:
			var current_num = lonely_spawner.get_num_nearby_friendlies()
			if(spawner.get_num_nearby_friendlies() < current_num):
				lonely_spawner = spawner
		return lonely_spawner

func _physics_process(delta: float) -> void:
	if(!spawns_locked):
		if(spawn_timer.is_stopped()):
			spawn_mobs()
			spawn_timer.start(spawn_timer_len_secs)
	
