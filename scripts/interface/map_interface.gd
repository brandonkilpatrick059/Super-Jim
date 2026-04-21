extends Node2D

@onready var scroll_list = $scroll_list
@onready var maps = $maps
@onready var map_name = $map_name

var timer := Timer.new()

var map_node : Node 

func close():
	queue_free()

func _ready():
	timer.one_shot = true
	add_child(timer)
	var player_ref = get_tree().get_first_node_in_group("player")
	var owned_maps = player_ref.get_owned_maps()
	var map_name : String = owned_maps[0]
	set_map(map_name)

func set_map(name : String):
	if(map_node != null):
		map_node.visible = false
	map_node = maps.find_child(name)
	scroll_list.set_map(map_node)
	map_node.visible = true
	map_name.parse_bbcode(name)

func _physics_process(delta: float) -> void:
	if(Input.is_action_just_pressed("menu_up")):
		scroll_list.decrement_selected()
	if(Input.is_action_just_pressed("menu_down")):
		scroll_list.increment_selected()
