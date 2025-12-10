extends Node

@export var is_hat : bool = false
@export var is_top : bool = false
@export var is_bottom : bool = false

@export var resource_path : String = ""

func _ready():
	pass

func run_script():
	var player_ref = get_tree().get_first_node_in_group("player")
	if(is_hat):
		player_ref.append_owned_hat(resource_path)
	elif(is_top):
		player_ref.append_owned_top(resource_path)
	elif(is_bottom):
		player_ref.append_owned_bottom(resource_path)
