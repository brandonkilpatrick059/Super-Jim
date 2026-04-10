extends Node

@export var groups : Array[String] = []
@export var keys : Array[String] = []

func run_script():
	var time_keeper = get_tree().get_first_node_in_group("time_keeper")
	var index : int = 0
	while(index < groups.size()):
		var group : String = groups[index]
		var key : String = keys[index]
		time_keeper.add_end_of_day_schedule_change(group,key)
		index = index + 1
