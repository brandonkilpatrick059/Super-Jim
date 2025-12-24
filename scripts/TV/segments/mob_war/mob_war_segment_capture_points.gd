extends Node2D

var active = false

var timer := Timer.new()

var audio_player := AudioStreamPlayer.new()

@onready var points = $points

func disable():
	active = false
	visible = false
	audio_player.stop()

func _ready():
	timer.one_shot = true
	add_child(timer)
	add_child(audio_player)
	audio_player.bus = "effects"
	audio_player.volume_db = -12.0

func set_active(set_active : bool):
	if(set_active == true && !active):
		active = true
		visible = true
	elif(set_active == false && active):
		active = false
		visible = false
		audio_player.stop()

func process():
	if(active):
		var children = points.get_children()
		for point in children:
			point.process()
