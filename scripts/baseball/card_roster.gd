extends Node2D

var cards : Array[Node2D]

func _ready():
	var children = get_children()
	for child in children:
		cards.append(child)

#everything's inclusive
func get_random_card(min : int, max : int, str_min : int = 0, str_max : int = 40) -> int:
	var index : int = min
	var fit_criteria : Array[int] = []
	while(index <= max):
		var card = get_card(index)
		if(card.get_strength_rating() <= str_max && 
		card.get_strength_rating() >= str_min):
			fit_criteria.append(index)
		index = index + 1
	var return_index = randi_range(0,fit_criteria.size())
	return fit_criteria[return_index]

func get_card(card_number : int):
	if(card_number - 1 < cards.size()):
		return cards[card_number - 1]
