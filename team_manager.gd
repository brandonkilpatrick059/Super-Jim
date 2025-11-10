extends Node2D

var red_spawners : Array[Node] = []
var blu_spawners : Array[Node] = []

var spawn_timer_len_secs = 5

var spawn_timer : Timer = Timer.new()

var num_mobs_to_spawn = 3

func _ready() -> void:
	spawn_timer.one_shot = true
	add_child(spawn_timer)
	
	var spawners = get_tree().get_nodes_in_group("capture_point")
	for spawner in spawners:
		if(spawner.is_in_group("red")):
			red_spawners.append(spawner)
		else:
			blu_spawners.append(spawner)
	
	spawn_timer.start(spawn_timer_len_secs)
	
func spawn_mobs():
	var temp_blu_spawners = blu_spawners.duplicate()
	var temp_red_spawners = red_spawners.duplicate()
	var num_red_mobs = 0
	var num_blu_mobs = 0
	var num_red_bandits = 0
	var num_blu_bandits = 0
	var current_mobs = get_tree().get_nodes_in_group("mobster")
	var num_tier_0 = 0
	var num_tier_1 = 0
	var num_tier_2 = 0
	for mob in current_mobs:
		var tier = mob.check_process_tier()
		match tier:
			0:
				num_tier_0 = num_tier_0 + 1
			1:
				num_tier_1 = num_tier_1 + 1
			2:
				num_tier_2 = num_tier_2 + 1
		if(mob.is_in_group("red")):
			num_red_mobs = num_red_mobs + 1
			if(mob.is_in_group("bandit")):
				num_red_bandits = num_red_bandits + 1
		elif(mob.is_in_group("blu")):
			num_blu_mobs = num_blu_mobs + 1
			if(mob.is_in_group("bandit")):
				num_blu_bandits = num_blu_bandits + 1
	var iter = 0
	print("=======================")
	print(str("Total Mobs-----", current_mobs.size()))
	print(str("Total Bandits:-", num_red_bandits + num_blu_bandits))
	print(str("Blu Mobs:------", num_blu_mobs))
	print(str("+Bandits:------", num_blu_bandits))
	print(str("+Goons:--------", num_blu_mobs - num_blu_bandits))
	print(str("Red Mobs:------", num_red_mobs))
	print(str("+Bandits:------", num_red_bandits))
	print(str("+Goons:--------", num_red_mobs - num_red_bandits))
	print(str("PROCESSING:"))
	print(str("T1: ", num_tier_0))
	print(str("T2: ", num_tier_1))
	print(str("T3: ", num_tier_2))
	while(iter < num_mobs_to_spawn):
		var red_spawner = get_loneliest_spawner(temp_red_spawners)
		var blu_spawner = get_loneliest_spawner(temp_blu_spawners)
		red_spawner.spawn_mob()
		if(temp_red_spawners.size() > 1):
			temp_red_spawners.remove_at(temp_red_spawners.find(red_spawner))
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
	if(spawn_timer.is_stopped()):
		spawn_mobs()
		spawn_timer.start(spawn_timer_len_secs)
	
