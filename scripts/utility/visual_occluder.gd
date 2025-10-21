extends Node2D

@export var occlusion_distance = 500
var is_occluding = false
var occluding_enabled = true
var player_ref

func _ready():
	player_ref = get_tree().get_first_node_in_group("player")
	add_to_group("visual_occluder")

func _physics_process(delta: float) -> void:
	if(occluding_enabled):
		var player_distance = global_position.distance_to(player_ref.global_position)
		if(player_distance < occlusion_distance):
			is_occluding = false
			get_parent().visible = true
		else:
			is_occluding = true
			get_parent().visible = false
	else:
		get_parent().visible = true
		
