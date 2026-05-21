extends Node2D

func _process(delta):
	var teleporter = get_parent()
	if(teleporter.is_entering() || 
	teleporter.is_exiting() || 
	teleporter.is_control_timer_active()):
		teleporter.update_fade_alpha()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var teleporter = get_parent()
	if(teleporter.is_entering() || 
	teleporter.is_exiting() || 
	teleporter.is_loading() ||
	teleporter.is_control_timer_active()):
		teleporter.set_fade_to_black_location(Vector2(0,0))
		if(Engine.is_editor_hint()):
			queue_redraw()
		if(teleporter.is_entering()):
			teleporter.enter()
		elif(teleporter.is_loading()):
			teleporter.load_wait() #pause to cover prune_manager full pass
		elif(teleporter.is_exiting()):
			teleporter.exit()
		elif(teleporter.is_control_timer_active() 
		&& teleporter.timer_control_back_is_stopped()):
			teleporter.set_control_timer_inactive()
			teleporter.set_exiting(false)
			var player_ref = get_tree().get_first_node_in_group("player")
			player_ref.set_control_frozen(false)
