extends Node2D

var active = false

@export var segments : Array[Node] = []

var time_keeper_ref = null

var active_segment : Node 

func _ready():
	pass

func set_active(set_active : bool):
	if(set_active && !active):
		active = true
		visible = true
		#todo: startup
	elif(!set_active && active):
		active = false
		visible = false
		#todo: cleanup

func update_active_segment():
	if(time_keeper_ref == null):
		time_keeper_ref = get_tree().get_first_node_in_group("time_keeper")
	var current_hour : int = time_keeper_ref.get_hour()
	var iter = 0 
	for segment in segments:
		if(iter == current_hour):
			active_segment = segment
			segment.set_active(true)
			break
		else:
			segment.set_active(false)
		iter = iter + 1

func process():
	update_active_segment()
	active_segment.process()
