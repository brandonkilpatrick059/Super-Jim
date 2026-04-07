extends Node2D

@onready var covers : Node2D = $covers
@onready var arrows: Node2D = $arrows

var player_ref = null

func _ready() -> void:
	player_ref = get_tree().get_first_node_in_group("player")
	if(player_ref.get_owned_music().size() > 1):
		arrows.visible = true
	else:
		arrows.visible = false

func set_cover(key : String):
	covers.set_cover(key)
