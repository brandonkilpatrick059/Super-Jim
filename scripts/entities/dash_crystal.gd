extends Node2D

@export var save_tag : String = ""

@onready var _collision : CollisionShape2D = $StaticBody2D/CollisionShape2D
@onready var _sprite = $Sprite2D
@onready var _animatedSprite = $AnimatedSprite2D

var gathered : bool = false

func interact():
	var player_ref = get_tree().get_first_node_in_group("player")
	player_ref.add_to_max_dash_secs(1)
	player_ref.regen_dash_secs(player_ref.get_max_dash_secs())
	queue_free()

func set_gathered():
	gathered = true
	_sprite.visible = false
	_animatedSprite.visible = false
	_collision.disabled = true

func get_save_dictionary() -> Dictionary:
	var save_dictionary = {
		"type" : "crystal",
		"save_tag" : save_tag,
		"gathered" : gathered
	}
	return save_dictionary


func load_from_dictionary(load_dictionary : Dictionary):
	if(load_dictionary.get("gathered")):
		set_gathered()
