extends Node

var map_id : RID

func _ready():
	map_id = NavigationServer2D.map_create()

func get_map_id():
	return map_id
