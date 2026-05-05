extends Node

@export var tab : String = ""

func run_conditional() -> int:
	var player_ref = get_tree().get_first_node_in_group("player")
	if player_ref.has_journal_tab(tab):
		return 1
	else:
		return 0
