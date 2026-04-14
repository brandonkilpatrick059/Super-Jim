extends Node2D

@export var visible_times : Array[bool] = []

var time_keeper
# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	time_keeper = get_tree().get_first_node_in_group("time_keeper")

func _physics_process(delta: float) -> void:
	var hour = time_keeper.get_hour()
	visible = visible_times[hour]
