extends Node

var total_pizzas_delivered : int = 0

var level : int = 0
#level = 0 : central area, 30 mobs (TUTORIAL)
#level = 1 : tier 1, 30 mobs
#level = 2 : tier 1-2, 56 mobs, bandits spawn
#level = 3 : tier 1-3, 60 mobs, bandits spawn
#level = 4 : tier 1-4 , 64 mobs, bandits spawn

var pizzas_delivered_today : int = 0

var pizza_checkpoints : Array[int] = [
	0, #0
	6, #1
	15, #2
	30, #3
	50, #4
]

var max_pizzas : Array[int] = [
	6, #level = 0
	6, #level = 1
	9, #level = 2
	9, #level = 3
	9  #level = 4
]

var tutorial_doors : Array[Node] = []

var is_leaving_tutorial : bool = false

var has_delivered_max_pizzas : bool = false

var doors_delivered_today : Array[Node]

func _ready() -> void:
	set_up_tutorial_doors()


func set_up_tutorial_doors():
	var delivery_doors = get_tree().get_nodes_in_group("delivery_door")
	var iterator = 0
	for door in delivery_doors:
		if(door.get_tier() == -2):
			tutorial_doors.append(door)
	for door in delivery_doors:
		if(door.get_tier() == -1):
			tutorial_doors.append(door)
	for door in delivery_doors:
		if(door.get_tier() == 0):
			tutorial_doors.append(door)

func get_is_leaving_tutorial() -> bool:
	return is_leaving_tutorial

func set_is_leaving_tutorial(value : bool):
	is_leaving_tutorial = value

func set_has_delivered_max_pizzas(value : bool):
	has_delivered_max_pizzas = value



#func get_mob_limit() -> int:
	#return mob_limits[level]

func get_level() -> int:
	return level

func set_level(num : int):
	level = num

func get_total_pizzas_delivered() -> int:
	return total_pizzas_delivered

func set_total_pizzas_delivered(num : int):
	total_pizzas_delivered = num

func add_pizzas_delivered(num : int, door : Node):
	total_pizzas_delivered = total_pizzas_delivered + num
	pizzas_delivered_today = pizzas_delivered_today + num
	if(max_pizzas[level] <= pizzas_delivered_today):
		has_delivered_max_pizzas = true
	update_level()
	doors_delivered_today.append(door)

func reset_pizzas_delivered_today():
	pizzas_delivered_today = 0
	has_delivered_max_pizzas = false
	doors_delivered_today.clear()

func has_hit_max_daily_deliveries():
	return has_delivered_max_pizzas

func update_level():
	var index = 0
	var check_level = 0
	for checkpoint in pizza_checkpoints:
		if(total_pizzas_delivered >= pizza_checkpoints[index]):
			check_level = index
		index = index + 1
	if(level == 0 && level != check_level):
		is_leaving_tutorial = true
		has_delivered_max_pizzas = true
	level = check_level

func restock_pizzas_at_end_of_day():
	var time_keeper = get_tree().get_first_node_in_group("time_keeper")
	var cook_ref = get_tree().get_first_node_in_group("cook")
	if(is_leaving_tutorial):
		cook_ref.set_schedules_key("gate") #conversation where gates are unlocked
		is_leaving_tutorial = false
	else:
		var key = cook_ref.get_schedules_key()
		if(key == "out_for_delivery"): #leaving a pizza out all night fails the delivery
			cook_ref.set_schedules_key("delivery_failed")
		elif(key == "no_pizzas"):
			cook_ref.set_schedules_key("delivery_dispenser")
	reset_pizzas_delivered_today()

#func leave_tutorial():
	#var time_keeper = get_tree().get_first_node_in_group("time_keeper")
	#var script_node = Node.new()
	#script_node.set_script(load("res://scripts/utility/adjust_schedules_index.gd"))
	#script_node.set_node_group("cook")
	#script_node.set_new_index(10)
	#time_keeper.add_end_of_day_script_node(script_node)

func get_delivery_tutorial_doors() -> Array[Node]:
	var selected_delivery_doors : Array[Node] = []
	var num_pizzas = 3
	var index = 0
	var pizzas_selected = 0
	while(pizzas_selected < num_pizzas &&
		index < tutorial_doors.size()):
		var tutorial_door = tutorial_doors[index]
		if(!doors_delivered_today.has(tutorial_door)):
			selected_delivery_doors.append(tutorial_door)
			pizzas_selected = pizzas_selected + 1
		index = index + 1

	#for door in selected_delivery_doors:
		#tutorial_doors.erase(door)

	return selected_delivery_doors

func get_delivery_doors_by_tier(tier: int, num_pizzas : int = 3) -> Array[Node]:
	var selected_delivery_doors : Array[Node] = []
	var delivery_doors = get_tree().get_nodes_in_group("delivery_door")
	var iterator = 0
	var doors_in_tier : Array[Node] = []
	selected_delivery_doors = []
	for door in delivery_doors:
		if(door.get_tier() <= tier &&
		door.get_tier() != 0 &&
		!doors_delivered_today.has(door)):
			doors_in_tier.append(door)
	while(iterator < num_pizzas):
		var random_index = randi_range(0,doors_in_tier.size()-1)
		var delivery_door = doors_in_tier[random_index]
		doors_in_tier.remove_at(random_index)
		selected_delivery_doors.append(delivery_door)
		#doors_delivered_today.append(delivery_door)
		iterator += 1
	return selected_delivery_doors
	

func get_delivery_doors() -> Array[Node]:
	if(level == 0):
		return get_delivery_tutorial_doors()
	else:
		return get_delivery_doors_by_tier(level)
