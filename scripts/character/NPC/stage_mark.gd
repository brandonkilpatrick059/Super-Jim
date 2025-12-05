class_name stage_mark
extends Node2D

@export var state : String

#TODO: this is setting up a situation where we're gonna need waaay too many stage_marks + schedules
#to support the more complex/varying characters. consider how to do more subtle iteration within the stage_mark?
@export var branching_dialog : dialog_tree

@export var passive_text : Array[String] = []

@export var reparent_to_daylight = false
@export var reparent_to_no_daylight = false
@export var reparent_to_dark_indoor = false

var random = RandomNumberGenerator.new()

func _ready():
	visible = false

func get_reparent_node() -> Node:
	var reparent_node 
	if(reparent_to_daylight):
		reparent_node = get_tree().get_first_node_in_group("daylight_affected_ysort")
	elif(reparent_to_no_daylight):
		reparent_node = get_tree().get_first_node_in_group("no_daylight_ysort")
	elif(reparent_to_dark_indoor):
		reparent_node = get_tree().get_first_node_in_group("dark_indoor_ysort")
	return reparent_node


func get_state():
	return state

func get_branching_dialog():
	return branching_dialog

func virtual_passive_text():
	return passive_text

func get_passive_text() -> String:
	if(passive_text.size() > 0):
		return virtual_passive_text()[random.randi_range(0, passive_text.size() - 1)]
	else:
		return ""
