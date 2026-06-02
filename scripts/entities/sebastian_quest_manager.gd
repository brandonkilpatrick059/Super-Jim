extends Node2D

@onready var lamp = $Lamp
@onready var TV = $TV

func _ready() -> void:
	remove_child(lamp)
	remove_child(TV)

func update_from_schedule():
	var sebastian = get_tree().get_first_node_in_group("sebastian")
	var current_key = sebastian.get_schedules_key()
	if(current_key == "has_lamp"):
		add_child(lamp)

func run_script():
	update_from_schedule()
