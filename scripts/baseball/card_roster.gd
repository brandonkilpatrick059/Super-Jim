extends Node2D

var cards : Array[Node2D]

func _ready():
	var children = get_children()
	for child in children:
		cards.append(child)


func get_card(card_number : int):
	if(card_number - 1 < cards.size()):
		return cards[card_number]
