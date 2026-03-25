extends Node2D

var mobster = preload("res://entities/characters/NPC/mobsters/mobster.tscn")
var hp_pizza = preload("res://entities/props/dynamic props/props_dynamic_pickupable/pizza/arcade_pizza.tscn")

@onready var center_label : Label = $center_label
@onready var remain_label : Label = $remain_label
@onready var wave_label : Label = $wave_label
@onready var hp_label : Label = $hp_label

var bandit_spawn : Node
var spawns : Array[Node] = []
var doors : Array[Node] = []

var wave_level = 0

var audio_player := AudioStreamPlayer.new()

var camera_ref = null 

var layer_index : int = 0
#0 = daylight
#1 = no light
#2 = dark

var camera_should_reset : bool = false

var player_bandit : Node = null
var enemy_mobs : Array[Node] = []

var home_team : String = "red"
var away_team : String = "blu"

var all_mobs_dead : bool = false

var timer := Timer.new()

var game_over : bool = false

var cabinet_ref = null

var cost : int = 5

var spawned_courier : bool = false
var courier : Node = null
var last_checked_size : int = 0

func _ready():
	audio_player.bus = "Effects"
	add_child(audio_player)
	var camera_ref = get_tree().get_first_node_in_group("camera")
	camera_ref.fade_in()
	timer.one_shot = true
	add_child(timer)

func set_home_team_blu():
	home_team = "blu"
	away_team = "red"

func set_spawns(new_bandit_spawn : Node, other_spawns : Array[Node]):
	bandit_spawn = new_bandit_spawn
	spawns = other_spawns

func set_doors(new_doors : Array[Node]):
	doors = new_doors

func set_cabinet_ref(ref : Node):
	cabinet_ref = ref

func set_layer_index(input : int):
	layer_index = input

func start_reset_camera():
	camera_should_reset = true

func reset_camera():
	var daylight_layer = get_tree().get_first_node_in_group("daylight_layer")
	var dark_layer = get_tree().get_first_node_in_group("dark_layer")
	match layer_index:
		0:
			daylight_layer.visible = true
			dark_layer.visible = false
			reparent(daylight_layer)
		1:
			daylight_layer.visible = false
			dark_layer.visible = false
		2:
			daylight_layer.visible = false
			dark_layer.visible = true
			reparent(dark_layer)
	var camera_ref = get_tree().get_first_node_in_group("camera")
	var player_ref = get_tree().get_first_node_in_group("player")
	camera_ref.connect_anchor(player_ref)

func start_game():
	var dark_layer = get_tree().get_first_node_in_group("dark_layer")
	dark_layer.visible = false
	player_bandit = mobster.instantiate()
	player_bandit.set_team(home_team)
	var ysort_node = get_tree().get_first_node_in_group("no_daylight_ysort")
	ysort_node.add_child(player_bandit)
	player_bandit.make_player_controlled()
	player_bandit.initialize_mob()
	player_bandit.make_bandit()
	player_bandit.global_position = bandit_spawn.global_position
	if(camera_ref == null):
		camera_ref = get_tree().get_first_node_in_group("camera")
	camera_ref.connect_anchor(player_bandit)
	generate_leveled_mob_wave()

func generate_leveled_mob_wave():
	center_label.text = str("WAVE ",wave_level+1)
	center_label.visible = true
	wave_label.text = str("WAVE ",wave_level+1)
	timer.start(3)
	match(wave_level):
		0:
			generate_mob_wave()
		1:
			generate_mob_wave(1)
		2:
			generate_mob_wave(2)
		3:
			generate_mob_wave(3)
		4:
			generate_mob_wave(4)
		5:
			generate_mob_wave()
			generate_mob_wave()
		6:
			generate_mob_wave()
			generate_mob_wave(1)
		7:
			generate_mob_wave()
			generate_mob_wave(2)
		8:
			generate_mob_wave()
			generate_mob_wave(3)
		9:
			generate_mob_wave()
			generate_mob_wave(4)

func generate_mob_wave(num_bandits : int = 0):
	spawned_courier = false
	for spawn in spawns:
		var new_mob = mobster.instantiate()
		new_mob.set_team(away_team)
		var ysort_node = get_tree().get_first_node_in_group("no_daylight_ysort")
		ysort_node.add_child(new_mob)
		new_mob.global_position = spawn.global_position
		var global_pos = new_mob.global_position
		new_mob.initialize_mob()
		if(num_bandits > 0):
			var not_aggressive : bool = true
			new_mob.make_bandit(not_aggressive)
			num_bandits = num_bandits - 1
		new_mob.transition_ai_state_machine(mobster_states.transit)
		enemy_mobs.append(new_mob)
	last_checked_size = enemy_mobs.size()

func spawn_courier():
	if(spawns.size() > 0 &&
	courier == null ||
	courier.get_hit_points() == 0):
		var spawn = spawns[randi_range(0,spawns.size()-1)]
		spawned_courier = true
		var new_mob = mobster.instantiate()
		new_mob.set_team(away_team)
		var ysort_node = get_tree().get_first_node_in_group("no_daylight_ysort")
		ysort_node.add_child(new_mob)
		new_mob.global_position = spawn.global_position
		var global_pos = new_mob.global_position
		new_mob.make_arcade_courier()
		new_mob.initialize_mob()
		new_mob.add_to_group("courier")
		var pizza = hp_pizza.instantiate()
		new_mob.add_child(pizza)
		new_mob._on_pick_up(pizza)
		new_mob.transition_ai_state_machine(mobster_states.courier_transit)
		courier = new_mob

func check_all_mobs_dead():
	var marked_mobs : Array[Node] = enemy_mobs.duplicate()
	enemy_mobs = []
	for mob in marked_mobs:
		if(mob != null && mob.get_hit_points() > 0):
			enemy_mobs.append(mob)
	
	if(last_checked_size > enemy_mobs.size()):
		last_checked_size = enemy_mobs.size()
		if(!spawned_courier): # && randf_range(0,1) > 0.5):
			spawn_courier()
	
	remain_label.text = str(enemy_mobs.size(), " REMAIN")
	
	if(enemy_mobs.size() == 0):
		all_mobs_dead = true
		wave_level = wave_level + 1

func check_player_dead():
	hp_label.text = str("HIT POINTS: ",player_bandit.get_hit_points())
	if(!game_over && player_bandit.get_hit_points() == 0):
		center_label.text = "GAME OVER"
		center_label.visible = true
		game_over = true
		timer.start(3)

func clean_up():
	reset_camera()
	for mob in enemy_mobs:
		mob.queue_free()
	player_bandit.queue_free()
	if(courier != null):
		courier.queue_free()
	queue_free()

func _physics_process(delta: float) -> void:
	check_all_mobs_dead()
	check_player_dead()
	if(timer.is_stopped()):
		center_label.visible = false
		if(game_over):
			game_over = false #?
			cabinet_ref.end_game()
	if(all_mobs_dead):
		all_mobs_dead = false
		generate_leveled_mob_wave()

func _process(delta: float) -> void:
	if(camera_ref == null):
		camera_ref = get_tree().get_first_node_in_group("camera")
	global_position = camera_ref.get_screen_center_position()
