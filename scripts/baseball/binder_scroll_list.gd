extends Node2D

@onready var tab_0 : Node2D = $tab_0
@onready var tab_1 : Node2D = $tab_1
@onready var tab_2 : Node2D = $tab_2
@onready var tab_3 : Node2D = $tab_3
@onready var tab_4 : Node2D = $tab_4
@onready var dial = $dial

var tabs : Array[Node2D]

var bottom_index = 1
var selected_index = 1

var card_roster = null
var player_ref = null

var dial_height = 116
var dial_step = 3.31

func _ready() -> void:
	tabs = [tab_0, tab_1, tab_2, tab_3, tab_4]
	card_roster = get_tree().get_first_node_in_group("card_roster")
	player_ref = get_tree().get_first_node_in_group("player")
	update_list()

func update_list():
	var owned_cards = player_ref.get_owned_cards()
	var index = bottom_index
	var tab = 0
	while(index < index + 4 && tab < 5):
		var state = "uncollected"
		var card_name = "???"
		var card = card_roster.get_card(index)
		if(owned_cards[index-1] > 0):
			state = "collected"
			card_name = card.get_card_name()
		if(index == selected_index):
			state = "selected"
		var team = card.get_team()
		tabs[tab].set_tab(index, card_name, state, team)
		tab = tab + 1
		index = index + 1

func get_selected_index():
	return selected_index

func get_selected_card():
	var owned_cards = player_ref.get_owned_cards()
	var card = null
	if(owned_cards[selected_index-1] > 0):
		card = card_roster.get_card(selected_index).duplicate()
	return card

func get_num_selected_card():
	var owned_cards = player_ref.get_owned_cards()
	return owned_cards[selected_index-1]


#func increment_selected_card():
	#player_ref.increment_owned_card(selected_index-1)
	#update_list()
#
#func decrement_selected_card():
	#player_ref.decrement_owned_card(selected_index-1)
	#update_list()

func increment_selected():
	if(selected_index + 1 <= 40):
		selected_index = selected_index + 1
		if(selected_index > bottom_index + 4 &&
		bottom_index + 5 <= 40):
			bottom_index = bottom_index + 1
			dial.position = dial.position + Vector2(0,dial_step)
	update_list()

func decrement_selected():
	if(selected_index - 1 > 0):
		selected_index = selected_index - 1
		if(selected_index < bottom_index &&
		bottom_index - 1 > 0):
			bottom_index = bottom_index - 1
			dial.position = dial.position - Vector2(0,dial_step)
	update_list()
