extends Node

var light = preload("res://entities/props/dynamic props/props_dynamic_pickupable/dreams/light_orb_light.tscn")

var can_create_light = true

func run_script():
	if(can_create_light):
		var new_light = light.instantiate()
		get_parent().add_child(new_light)
		can_create_light = false
		
func run_return_script():
	can_create_light = true
	var children = get_parent().get_children()
	for child in children:
		if(child.is_in_group("dream_light_source")):
			child.queue_free()
