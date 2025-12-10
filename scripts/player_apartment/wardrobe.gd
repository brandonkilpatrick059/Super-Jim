extends StaticBody2D

var interface = preload("res://interface/clothing_interface.tscn")

func interact():
	var clothes_interface = interface.instantiate()
	var player_ref = get_tree().get_first_node_in_group("player")
	player_ref.get_parent().add_child(clothes_interface)
	
