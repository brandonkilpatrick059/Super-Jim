extends Area2D

var ledge_checker_active : bool = false
@onready var ledge_checker : Area2D = $ledge_checker

func _ready() -> void:
	remove_child(ledge_checker)

func enter_fall_zone():
	get_parent().enter_fall_zone()

func exit_fall_zone():
	get_parent().exit_fall_zone()

func reset_ledge_checker():
	if(ledge_checker_active):
		ledge_checker_active = false
		remove_child(ledge_checker)

func check_ledge() -> bool:
	if(!ledge_checker_active):
		ledge_checker_active = true
		add_child(ledge_checker)
	var areas : Array[Area2D] = ledge_checker.get_overlapping_areas()
	var ledge_found = true
	if(areas.size() > 0):
		ledge_found = false
	return ledge_found
