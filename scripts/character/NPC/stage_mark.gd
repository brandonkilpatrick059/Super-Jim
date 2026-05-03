class_name stage_mark
extends Node2D

@export var state : String

@export var branching_dialog : dialog_tree

@export var branching_dialogs : Array[dialog_tree] = []
@export var dialog_conditional : Node = null

@export var passive_text : Array[String] = []

@export var reparent_to_daylight = false
@export var reparent_to_no_daylight = false
@export var reparent_to_dark_indoor = false

@export var random_wait_secs : float = 0.0
@export var passive_face_dir : String = ""

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

func get_passive_face_dir() -> String:
	return passive_face_dir

func get_wait_time():
	return random_wait_secs

func get_state():
	return state

func get_branching_dialog():
	if(dialog_conditional == null):
		return branching_dialog
	else:
		var index = dialog_conditional.run_conditional()
		return branching_dialogs[index]

func virtual_passive_text():
	return passive_text

func get_passive_text() -> String:
	if(passive_text.size() > 0):
		return virtual_passive_text()[random.randi_range(0, passive_text.size() - 1)]
	else:
		return ""
