extends Node2D

@export var deck_left_array : Array [int] = []
@export var deck_right_array : Array [int] = []
@export var deck_right_catch_chances : Array [float] = []

func _ready() -> void:
	var card_game = get_child(0)
	card_game.set_callback_node(self)
	card_game.initiate_card_game(deck_left_array,deck_right_array,deck_right_catch_chances)

func game_end(player_won : int):
	pass
