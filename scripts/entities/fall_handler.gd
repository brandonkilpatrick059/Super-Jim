extends Area2D


func enter_fall_zone():
	get_parent().enter_fall_zone()

func exit_fall_zone():
	get_parent().exit_fall_zone()
