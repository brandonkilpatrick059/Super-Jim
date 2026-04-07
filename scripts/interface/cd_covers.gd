extends Node2D

func set_cover(key : String):
	var children = get_children()
	for child in children:
		child.visible = false
		if(child.name == key):
			child.visible = true
