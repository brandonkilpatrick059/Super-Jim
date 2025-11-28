extends Node2D

@onready var lineup_1 : Node2D = $lineup_1
@onready var lineup_2 : Node2D = $lineup_2
@onready var lineup_3 : Node2D = $lineup_3
@onready var lineup_4 : Node2D = $lineup_4
@onready var lineup_5 : Node2D = $lineup_5

var index = 0
var lineup : Array[Node2D]

var card_roster = null

func _ready() -> void:
	lineup = [lineup_1, lineup_2, lineup_3, lineup_4, lineup_5]

func set_lineup(deck : Array[int]):
	index = 0
	while(index < deck.size()):
		var num = deck[index]
		var card = get_card(num)
		lineup[index].add_child(card)
		card.position = Vector2(0,0)
		card.visible = true
		index = index + 1

func get_card(num : int) -> Node2D:
	if(card_roster == null):
		card_roster = get_tree().get_first_node_in_group("card_roster")
	var card = card_roster.get_card(num).duplicate()
	return card

func add_card(num : int):
	if(index < lineup.size()):
		var card = get_card(num)
		lineup[index].add_child(card)
		card.position = Vector2(0,0)
		card.visible = true
		index = index + 1

func subtract_card():
	if(index - 1 >= 0):
		index = index - 1
		lineup[index].get_children()[0].queue_free()
