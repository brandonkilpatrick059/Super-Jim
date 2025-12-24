extends AnimatedSprite2D

@export var connected_spawner : String = ""

var is_blu = true

var spawner_ref : Node = null

var is_contested = false

var timer := Timer.new()

func _ready():
	timer.one_shot = true
	add_child(timer)

func process():
	if(spawner_ref == null):
		spawner_ref = get_tree().get_first_node_in_group(connected_spawner)
	var team = spawner_ref.get_team()
	is_contested = spawner_ref.get_is_contested()
	if(is_contested):
		if(timer.is_stopped()):
			visible = !visible
			timer.start(0.5)
	else:
		visible = true
	play(team)
