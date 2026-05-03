extends Area2D

@export var only_lost_cat : bool = false

var pick_cat_group = "pickupable_cat"
var cat_group = "cat"

func _ready() -> void:
	if(only_lost_cat):
		pick_cat_group = "lost_cat"
		cat_group = "lost_cat"

func _on_body_entered(body: Node2D) -> void:
	if(only_lost_cat && lost_cat_found() || !only_lost_cat):
		if(body.is_in_group("player")):
			if(body.get_grabbed_object() != null &&
			body.get_grabbed_object().is_in_group(pick_cat_group)):
				if(!body.control_is_frozen()):
					body.put_down()
					body._on_make_comment("The cat escaped!")
			body.add_forbidden_interact(cat_group)


func _on_body_exited(body: Node2D) -> void:
	if(only_lost_cat && lost_cat_found() || !only_lost_cat):
		if(body.is_in_group("player")):
			body.remove_forbidden_interact(cat_group)

func lost_cat_found() -> bool:
	var player_ref = get_tree().get_first_node_in_group("player")
	var state : String = player_ref.get_quest_state("lost_cat")
	var found = false
	if(state == "FOUND"):
		found = true
	return found
