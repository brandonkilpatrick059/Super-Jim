extends Node

var card_pack = preload("res://baseball/card_pack.tscn")

@export var roster_min : int = 0
@export var roster_max : int = 0
@export var roster_team : String = ""

func run_script():
	var cards = card_pack.instantiate()
	var player_ref = get_tree().get_first_node_in_group("player")
	var parent = player_ref.get_parent()
	cards.visible = false
	parent.add_child(cards)
	cards.global_position = player_ref.get_camera_ref().get_screen_center_position()
	cards.visible = true
	cards.open(roster_min,roster_max,roster_team)
