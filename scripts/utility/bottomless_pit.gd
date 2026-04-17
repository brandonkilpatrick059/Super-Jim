extends Area2D

func _on_body_entered(body : Node2D):
	if(body.is_in_group("fall_handler")):
		body.enter_fall_zone()
			
func _on_body_exited(body : Node2D):
	if(body.is_in_group("fall_handler")):
		body.exit_fall_zone()

func _on_area_entered(area : Area2D):
	if(area.is_in_group("fall_handler")):
		area.enter_fall_zone()
			
func _on_area_exited(area : Area2D):
	if(area.is_in_group("fall_handler")):
		area.exit_fall_zone()
