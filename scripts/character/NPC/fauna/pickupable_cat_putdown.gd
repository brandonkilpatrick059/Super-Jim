extends Node

@export var npc_cat_path : String = ""

func run_script():
	var npc_cat = load(npc_cat_path)
	var cat = npc_cat.instantiate()
	cat.global_position = get_parent().global_position
	get_parent().get_parent().add_child(cat)
	get_parent().queue_free()
