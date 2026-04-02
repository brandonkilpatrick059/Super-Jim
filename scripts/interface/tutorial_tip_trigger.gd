extends Node

@export_multiline var tip_text : String = ""

@export var actions_1 : Array[String] = []
@export var actions_2 : Array[String] = []
@export var actions_3 : Array[String] = []

@export var show_left_arrow : bool = false
@export var show_right_arrow : bool = false
@export var play_once : bool = false

@export var conditional_script_node : Node = null

@export var save_tag : String = ""

var has_played = false

func body_entered_trigger(body : Node2D):
	if(play_once && has_played):
		pass
	else:
		if(conditional_script_node == null):
			show_tip()
		elif(conditional_script_node.run_conditional()):
			show_tip()

func body_exited_trigger(body : Node2D):
	hide_tip()

func show_tip():
	has_played = true
	var player = get_tree().get_first_node_in_group("player")
	if(player != null):
		player.show_tip(tip_text,show_left_arrow,show_right_arrow,
		actions_1,actions_2,actions_3)

func hide_tip():
	var player = get_tree().get_first_node_in_group("player")
	if(player != null):
		player.hide_tip()


func get_save_tag() -> String: return save_tag

func get_save_dictionary() -> Dictionary:
	var save_dictionary = {
		"type" : "tip_trigger",
		"save_tag" : get_save_tag(),
		"has_has_played" : has_played 
	}
	return save_dictionary

func load_from_dictionary(load_dictionary : Dictionary):
	has_played = load_dictionary.get("has_played")
