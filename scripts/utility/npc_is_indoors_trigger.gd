extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if(body.is_in_group("npc") or 
	body.is_in_group("npc_alternative")):
		body.set_is_indoors(true)


func _on_body_exited(body: Node2D) -> void:
	if(body.is_in_group("npc") or 
	body.is_in_group("npc_alternative")):
		body.set_is_indoors(false)
