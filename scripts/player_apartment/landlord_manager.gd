extends Node2D

var active = false
var time_keeper = null
var player_ref = null
var landlord_ref = null

#dialog trees
@export var end_of_day_script : Node
@export var collect : Node
@export var locked : Node
@export var start : Node

var rent = 20
var rent_locked = false
var owed_money = 0

var start_mode = false
var active_mode = true

func add_rent():
	if(!rent_locked):
		if(owed_money < rent * 2):
			owed_money = owed_money + rent
		else:
			var door = get_tree().get_first_node_in_group("player_apartment_door")
			door.lock()
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

func landlord_inactive():
	landlord_ref.set_schedules_index(0)
	start_mode = false
	active_mode = false
	var time_keeper = get_tree().get_first_node_in_group("time_keeper")
	var node = end_of_day_script.duplicate()
	time_keeper.add_end_of_day_script_node(node)

func catch_player():
	if(start_mode):
		landlord_ref._on_set_branching_dialog(start)
		landlord_ref.interact()
		landlord_inactive()
	elif(active_mode):
		var player_money = player_ref.get_money()
		if(player_money >= owed_money):
			landlord_ref._on_set_branching_dialog(collect)
			landlord_ref._on_stop_motion()
			landlord_ref.interact()
			landlord_inactive()
			owed_money = 0
			var door = get_tree().get_first_node_in_group("player_apartment_door")
			door.unlock()
		elif(player_money < owed_money):
			landlord_ref._on_set_branching_dialog(locked)
			landlord_ref._on_stop_motion()
			landlord_ref.interact()
			landlord_inactive()
			var door = get_tree().get_first_node_in_group("player_apartment_door")
			door.lock()
