extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if(body.is_in_group("player")):
		if(body.get_grabbed_object() != null &&
		body.get_grabbed_object().is_in_group("pickupable_cat")):
			if(!body.control_is_frozen()):
				body.put_down()
				body._on_make_comment("The cat escaped!")
		body.add_forbidden_interact("cat")


func _on_body_exited(body: Node2D) -> void:
	if(body.is_in_group("player")):
		body.remove_forbidden_interact("cat")
