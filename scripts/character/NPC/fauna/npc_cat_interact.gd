extends Node

@export var pickupable_cat_path : String = ""
@export var pickupable_cat_path_docile : String = ""

func interact():
	var player_ref = get_tree().get_first_node_in_group("player")
	if(not player_ref.get_holding_object()):
		var pickupable_cat
		if(get_parent().find_child("ai_state_machine").get_state().name == "eating"):
			pickupable_cat = load(pickupable_cat_path_docile)
		else:
			pickupable_cat = load(pickupable_cat_path)
		var pick_cat = pickupable_cat.instantiate()
		get_parent().get_parent().add_child(pick_cat)
		pick_cat.pick_up(player_ref)
		player_ref.set_grabbed_object(pick_cat)
		player_ref.set_holding_object(true)
		var pickup_sound = load("res://audio/soundFX/pickup.wav")
		player_ref.play_sound(pickup_sound)
		get_parent().queue_free()
