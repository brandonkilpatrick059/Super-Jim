extends Node

var total_pizzas_delivered : int = 0

var level : int = 0
#level = 0 : central area, 40 mobs (TUTORIAL)
#level = 1 : tier 1, 40 mobs
#level = 2 : tier 1-2, 48 mobs
#level = 3 : tier 1-3, 56 mobs, capture points active
#level = 4 : tier 1-4 , 64 mobs, capture points active

var pizza_checkpoints : Array[int] = [
	0, #0
	6, #1
	18, #2
	30, #3
	42, #4
]

var mob_limits : Array[int] = [
	40, #level = 0
	40, #level = 1
	48, #level = 2
	56, #level = 3
	64  #level = 4
]

var tutorial_doors : Array[Node] = []

func _ready() -> void:
	add_to_group("pizza_manager")
	set_up_tutorial_doors()

func set_up_tutorial_doors():
	var delivery_doors = get_tree().get_nodes_in_group("delivery_door")
	var iterator = 0
	for door in delivery_doors:
		if(door.get_tier() == 0):
			tutorial_doors.append(door)

func get_mob_limit() -> int:
	return mob_limits[level]

func get_level() -> int:
	return level

func set_level(num : int):
	level = num

func get_total_pizzas_delivered() -> int:
	return total_pizzas_delivered

func set_total_pizzas_delivered(num : int):
	total_pizzas_delivered = num
	update_level()

func add_pizzas_delivered(num : int):
	total_pizzas_delivered = total_pizzas_delivered + num
	update_level()

func update_level():
	var index = 0
	var check_level = 0
	for checkpoint in pizza_checkpoints:
		if(total_pizzas_delivered >= pizza_checkpoints[index]):
			check_level = index
		index = index + 1
	level = check_level

func get_tutorial_doors() -> Array[Node]:
	var selected_delivery_doors : Array[Node] = []
	var num_pizzas = 3
	var index = 0
	while(index < num_pizzas):
		selected_delivery_doors.append(selected_delivery_doors[index])
		index = index + 1

	for door in selected_delivery_doors:
		selected_delivery_doors.erase(door)

	return selected_delivery_doors

func get_delivery_doors_by_tier(tier: int, num_pizzas : int = 3) -> Array[Node]:
	var selected_delivery_doors : Array[Node] = []
	var delivery_doors = get_tree().get_nodes_in_group("delivery_door")
	var iterator = 0
	var doors_in_tier : Array[Node] = []
	selected_delivery_doors = []
	for door in delivery_doors:
		if(door.get_tier() <= tier):
			doors_in_tier.append(door)
	while(iterator < num_pizzas):
		var random_index = randi_range(0,doors_in_tier.size()-1)
		var delivery_door = doors_in_tier[random_index]
		doors_in_tier.remove_at(random_index)
		selected_delivery_doors.append(delivery_door)
		iterator += 1
	return selected_delivery_doors
	

func get_delivery_doors() -> Array[Node]:
	if(level == 0):
		return get_tutorial_doors()
	else:
		return get_delivery_doors_by_tier(level)
