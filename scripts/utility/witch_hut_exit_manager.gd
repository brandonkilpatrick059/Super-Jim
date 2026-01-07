extends Node2D

@onready var sewer_exit = $sewers_witch_hut_exit
@onready var caves_exit = $caves_witch_hut_exit

var opossums :  Array[Node] = []

func _ready() -> void:
	opossums = get_tree().get_nodes_in_group("opossum")

#the house boat is in the sewers
func activate_sewer_exit():
	sewer_exit.make_active()
	caves_exit.make_inactive()
	for opossum in opossums:
		opossum.set_schedules_index(0)

#the house boat is in the caves
func activate_caves_exit():
	caves_exit.make_active()
	sewer_exit.make_inactive()
	for opossum in opossums:
		opossum.set_schedules_index(1)
