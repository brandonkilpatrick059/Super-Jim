extends Node2D

@onready var lamp = $Lamp
@onready var TV = $TV
@onready var tail = $sebastian_tail

func _ready() -> void:
	remove_child(lamp)
	remove_child(TV)

func update_from_schedule():
	var sebastian = get_tree().get_first_node_in_group("sebastian")
	var current_key = sebastian.get_schedules_key()
	if(current_key == "has_lamp" ||
	current_key == "has_pizza"):
		add_child(lamp)
	if(current_key == "has_tv"):
		add_child(lamp)
		add_child(TV)
	elif(current_key == "scooched"):
		add_child(lamp)
		add_child(TV)
		remove_child(tail)

func reset_interact_trigger():
	var trigger = get_tree().get_first_node_in_group("sebastian_interact_trigger")
	trigger.reset_has_played()

func run_script():
	update_from_schedule()
	reset_interact_trigger()
