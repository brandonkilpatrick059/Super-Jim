class_name daily_schedule
extends Node

#stage_mark nodes representing where an NPC should be at a given hour
#should have size of 24 (duh)
@export var hourly_schedule : Array[Node] = []
@export var full_day_schedule : Node = null

func get_stage_mark(hour : int) -> Node:
	if(full_day_schedule != null):
		return full_day_schedule
	else:
		return hourly_schedule[hour]

func get_stage_marks() -> Array[Node]:
	if(full_day_schedule != null):
		return [full_day_schedule]
	else:
		return hourly_schedule
