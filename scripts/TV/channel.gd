extends Node2D

var active = false

@export var segments : Array[Node] = []
@export var channel_text : String = ""

var time_keeper_ref = null

var active_segment : Node 

var current_hour = 0

var should_disable : bool = true

func _ready():
	active = false
	visible = false
	#for segment in segments:
		#segment.disable()

func get_channel_text() -> String:
	return channel_text

func set_active(set_active : bool):
	if(set_active && !active):
		active = true
		visible = true
	elif(!set_active && active):
		active = false
		visible = false
		disable_segments()

func disable_segments():
	for segment in segments:
		segment.disable()

func update_active_segment():
	if(time_keeper_ref == null):
		time_keeper_ref = get_tree().get_first_node_in_group("time_keeper")
	current_hour = time_keeper_ref.get_hour()
	var iter = 0 
	if(should_disable):
		for segment in segments:
			segment.disable()
		should_disable = false
	if(active):
		for segment in segments:
			if(iter == current_hour):
				active_segment = segment
				segment.set_active(true)
			elif(segment != active_segment):
				segment.set_active(false)
			iter = iter + 1

func _process(delta: float) -> void:
	update_active_segment()

func process():
	if(active_segment != null):
		active_segment.process()
