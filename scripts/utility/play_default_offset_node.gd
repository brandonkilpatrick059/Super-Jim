extends Node

func _process(delta : float) -> void:
	if(get_parent().is_timer_stopped()):
		get_parent().play_default_animation()
		queue_free()
