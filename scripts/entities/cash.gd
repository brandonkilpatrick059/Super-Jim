extends StaticBody2D

var save_tag : String = ""
var gathered : bool = false

@onready var _collision : CollisionShape2D = $CollisionShape2D
@onready var _sprite = $Sprite2D

@export var amount : int

# Called when the node enters the scene tree for the first time.
func _ready():
	save_tag = get_path().get_concatenated_names().get_basename()

func interact():
	var player_ref= get_tree().get_first_node_in_group("player")
	player_ref._on_make_comment(str("Cool! $",amount))
	player_ref._on_add_money(amount)
	queue_free()

func get_save_tag():
	return save_tag

func set_gathered():
	gathered = true
	_sprite.visible = false
	_collision.disabled = true

func get_save_dictionary() -> Dictionary:
	var save_dictionary = {
		"type" : "cash",
		"save_tag" : save_tag,
		"gathered" : gathered
	}
	return save_dictionary

func load_from_dictionary(load_dictionary : Dictionary):
	if(load_dictionary.get("gathered")):
		set_gathered()
