extends Node

var pause_menu = preload("res://menu/pause menu/pause_menu_manager.tscn")

@export var clock = 0.0
@export var hour_length_seconds = 30.0
var sound_player := AudioStreamPlayer.new()
var is_menu_paused = false
var is_game_over = false
var is_playing_song = false
var play_song_wait_sec = 1
var timer_world := Timer.new()
var timer_song := Timer.new()
var timer_restart := Timer.new()
var ambient_dark = null
var days_passed : int = 0

var end_of_day_script_queue : Array[Node] = []

var time_locked = true

signal new_day()

var day_of_the_week = 0
var days_in_week = [
	"Sunday",
	"Monday",
	"Tuesday",
	"Wednesday",
	"Thursday",
	"Friday",
	"Saturday"
]

var restart_wait_sec = 30

var player_ref = null

var pause_menu_ref = null

func get_days_passed() -> int:
	return days_passed

func get_day_of_week():
	return day_of_the_week

func set_day_of_week(input : int):
	day_of_the_week = input

func set_days_passed(input : int):
	days_passed = input

func get_hour():
	return clock

func unlock_time():
	time_locked = false

func lock_time():
	time_locked = true

func get_hour_length_seconds():
	return hour_length_seconds

func refresh_npc_locations():
	var npcs = get_tree().get_nodes_in_group("npc")
	for npc in npcs:
		npc.teleport_and_update()

#Called when the node enters the scene tree for the first time.
func _ready():
	sound_player.bus = "Music"
	add_child(sound_player)
	timer_world.one_shot = true
	timer_world.process_mode = Node.PROCESS_MODE_PAUSABLE
	timer_song.one_shot = true
	timer_restart.one_shot = true
	add_child(timer_world)
	add_child(timer_song)
	add_child(timer_restart)
	timer_world.start(hour_length_seconds)
	ambient_dark = get_tree().get_first_node_in_group("ambient_dark")
	player_ref = get_tree().get_first_node_in_group("player")

func get_time_as_ratio_of_full_day() -> float:
	var ratio = 0.0
	ratio = (clock+1.0)/24.0
	ratio += ((hour_length_seconds - timer_world.time_left)/hour_length_seconds) * (1.0/24.0)
	return ratio

func toggle_pause_parent_tree():
	if(!get_parent().get_tree().paused):
		pause_parent_tree()
	else:
		unpause_parent_tree()

func pause_parent_tree(music_continues : bool = false):
	get_parent().get_tree().paused = true
	if(!music_continues):
		var main_music_player = get_tree().get_first_node_in_group("main_music_player")
		main_music_player.pause()

func unpause_parent_tree():
	get_parent().get_tree().paused = false
	var main_music_player = get_tree().get_first_node_in_group("main_music_player")
	main_music_player.unpause()

func toggle_menu_pause():
	if(!is_game_over):
		if(!is_menu_paused):
			if(!player_ref.control_frozen):
				open_pause_menu()
		else:
			close_pause_menu()

func open_pause_menu():
	pause_menu_ref = pause_menu.instantiate()
	player_ref.control_frozen = true
	player_ref.add_child(pause_menu_ref)
	is_menu_paused = true
	sound_player.stream = load("res://audio/soundFX/opened.wav")
	sound_player.play()
	toggle_pause_parent_tree()
	timer_song.start(play_song_wait_sec)

func close_pause_menu():
	pause_menu_ref.queue_free()
	player_ref.control_frozen = false
	is_menu_paused = false
	is_playing_song = false
	sound_player.stream = load("res://audio/soundFX/closed.wav")
	sound_player.play()
	toggle_pause_parent_tree()

func game_over():
	is_game_over = true
	toggle_pause_parent_tree()
	ambient_dark.fade_to_black()

#func game_continue():
	#ambient_dark.end_fade()
	#toggle_pause_parent_tree()
	#is_game_over = false

func get_informal_time_string() -> String:
	var informal_string = ""
	if(clock > 11):
		if(clock == 12):
			informal_string = str(12, " PM")
		else:
			informal_string = str(int(clock) - 12, " PM")
	else:
		if(clock == 0):
			informal_string = str (12, " AM")
		else:
			informal_string = str (int(clock), " AM")
	informal_string = str(informal_string, ", ", days_in_week[day_of_the_week])
	return informal_string

func get_input():
	if Input.is_action_just_pressed("start"):
		if(!is_game_over):
			toggle_menu_pause()
		elif(is_game_over):
			var ref = get_tree().get_first_node_in_group("player_die")
			if(ref.animation_finished()):
				unpause_parent_tree()
				get_tree().change_scene_to_file("res://scenes/start_menu.tscn")
	if Input.is_action_just_pressed("interact"):
		if(is_game_over):
			var ref = get_tree().get_first_node_in_group("player_die")
			if(ref.animation_finished()):
				unpause_parent_tree()
				get_tree().change_scene_to_file("res://scenes/start_menu.tscn")

func add_end_of_day_script_node(script_node : Node):
	add_child(script_node)
	end_of_day_script_queue.append(script_node)

func set_clock(hour : int):
	clock = hour
	refresh_npc_locations()
	hourly_update_objects()

func advance_day():
	if(day_of_the_week == 6):
		day_of_the_week = 0
	else:
		day_of_the_week = day_of_the_week + 1
		
	for node in end_of_day_script_queue:
		node.run_script()
		node.queue_free()
	end_of_day_script_queue = []
	days_passed = days_passed + 1
	daily_update_objects()

func advance_clock():
	if(clock != 23):
		clock = clock + 1
	else: if(clock == 23):
		clock = 0
		advance_day()
	hourly_update_objects()

func daily_update_objects():
	update_shops()
	update_landlord()
	update_pizzas()

func hourly_update_objects():
	update_lights()

func update_shops():
	var shops = get_tree().get_nodes_in_group("shop_manager")
	for shop in shops:
		shop.shuffle_staged_items()

func update_landlord():
	var landlord_manager = get_tree().get_first_node_in_group("landlord_manager")
	landlord_manager.add_rent()

func update_lights():
	var lights = get_tree().get_nodes_in_group("timed_light")
	for light in lights:
		light.update_light()

func update_pizzas():
	var pizza_manager = get_tree().get_first_node_in_group("pizza_manager")
	pizza_manager.reset_pizzas_delivered_today()
	pizza_manager.restock_pizzas_at_end_of_day()

#Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	get_input()
	if(!is_menu_paused):
		#calculate clock
		if(timer_world.is_stopped() && not time_locked):
			timer_world.start(hour_length_seconds)
			advance_clock()
	elif (is_menu_paused && !is_playing_song && timer_song.is_stopped()):
		is_playing_song = true

	if(player_ref != null):
		if(player_ref.dead && !is_game_over):
			game_over()
		
