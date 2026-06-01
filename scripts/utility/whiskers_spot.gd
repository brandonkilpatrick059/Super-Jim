extends Area2D

var whiskers = preload("res://entities/characters/NPC/animatronics/npc_whiskers.tscn")

@export var moon_phase : String = ""
@export var parent_group : String = ""

var whiskers_ref : Node 
var whiskers_active : bool = false

func _on_body_entered(body : Node):
	if(body.is_in_group("player")):
		var time_keeper = get_tree().get_first_node_in_group("time_keeper")
		var current_phase = time_keeper.get_moon_phase()
		if(current_phase == moon_phase):
			whiskers_ref = whiskers.instantiate()
			var parent = get_tree().get_first_node_in_group(parent_group)
			parent.add_child(whiskers_ref)
			var shop = get_tree().get_first_node_in_group("whiskers_shop")
			shop.set_wares_visible(true)
			whiskers_ref.global_position = global_position
			whiskers_ref.update_shop()
			whiskers_active = true

func _on_body_exited(body : Node):
	if(body.is_in_group("player") && whiskers_active):
		whiskers_active = false
		var shop = get_tree().get_first_node_in_group("whiskers_shop")
		shop.set_wares_visible(false)
		whiskers_ref.queue_free()
