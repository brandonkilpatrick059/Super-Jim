extends Node

@export_multiline var tip_text : String = ""

@export var actions_1 : Array[String] = []
@export var actions_2 : Array[String] = []
@export var actions_3 : Array[String] = []

@export var show_left_arrow : bool = false
@export var show_right_arrow : bool = false

func body_entered_trigger(body : Node2D):
	show_tip()

func body_exited_trigger(body : Node2D):
	hide_tip()

func show_tip():
	var player = get_tree().get_first_node_in_group("player")
	player.show_tip(tip_text,show_left_arrow,show_right_arrow,
	actions_1,actions_2,actions_3)

func hide_tip():
	var player = get_tree().get_first_node_in_group("player")
	player.hide_tip()
