extends AnimatedSprite2D

@export var connected_spawner : String = ""

var is_blu = true

var spawner_ref : Node = null

#todo: IMPLEMENT
var is_contested = false

func process():
	if(spawner_ref == null):
		spawner_ref = get_tree().get_first_node_in_group(connected_spawner)
	var team = spawner_ref.get_team()
	play(team)
