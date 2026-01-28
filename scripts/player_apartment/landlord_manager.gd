extends Node2D

var active = false
var time_keeper = null
var player_ref = null
var landlord_ref = null

#dialog trees
@export var end_of_day_script : Node
@export var collect : Node
@export var collect_unlocked : Node
@export var locked : Node
@export var warning : Node
@export var start : Node

var rent = 30
var apartment_locked = false
var rent_locked = false
var warned = false

var start_mode = false
var active_mode = true
var wait_mode = false

var stream_temp : String = ""

func add_rent():
	if(!rent_locked):
		var days_since_paid = player_ref.get_days_since_paid_rent()
		player_ref.set_days_since_paid_rent(days_since_paid + 1)
		check_if_rent_overdue()

func check_if_rent_overdue():
	var days_since_paid = player_ref.get_days_since_paid_rent()
	if(days_since_paid > 2):
		landlord_active_wait()
	else:
		landlord_active()

func _ready() -> void:
	time_keeper = get_tree().get_first_node_in_group("time_keeper")
	player_ref = get_tree().get_first_node_in_group("player")
	landlord_ref = get_tree().get_first_node_in_group("landlord")

func set_active():
	active = true

func landlord_start():
	landlord_ref.set_schedules_index(2)
	landlord_ref.teleport_and_update()
	start_mode = true
	active_mode = false

func landlord_active():
	landlord_ref.set_schedules_index(1)
	start_mode = false
	active_mode = true
	wait_mode = false

func landlord_active_wait():
	landlord_ref.set_schedules_index(2)
	start_mode = false
	active_mode = true
	wait_mode = true

func landlord_inactive():
	landlord_ref.set_schedules_index(0)
	start_mode = false
	active_mode = false
	var time_keeper = get_tree().get_first_node_in_group("time_keeper")

func lock_player_apartment():
	apartment_locked = true
	var door = get_tree().get_first_node_in_group("player_apartment_door")
	door.lock()

func unlock_player_apartment():
	apartment_locked = false

func catch_finish():
	var main_music_player = get_tree().get_first_node_in_group("main_music_player")
	main_music_player.change_stream(stream_temp)
	landlord_inactive()

func catch_player():
	var main_music_player = get_tree().get_first_node_in_group("main_music_player")
	stream_temp = main_music_player.get_stream_name()
	main_music_player.change_stream("res://audio/music/landlords_theme.wav")
	if(start_mode):
		landlord_ref._on_set_branching_dialog(start)
		landlord_ref.interact()
	elif(active_mode):
		var player_money = player_ref.get_money()
		if(player_money > 0):
			if(apartment_locked):
				landlord_ref._on_set_branching_dialog(collect_unlocked)
			else:
				landlord_ref._on_set_branching_dialog(collect)
			landlord_ref._on_stop_motion()
			landlord_ref.interact()
			player_ref.set_days_since_paid_rent(0)
			warned = false
			unlock_player_apartment()
		elif(player_money <= 0):
			if(!warned):
				warned = true
				landlord_ref._on_set_branching_dialog(warning)
			else:
				landlord_ref._on_set_branching_dialog(locked)
				lock_player_apartment()
			landlord_ref._on_stop_motion()
			landlord_ref.interact()
			
			
