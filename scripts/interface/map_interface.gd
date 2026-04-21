extends Node2D

@onready var scroll_list = $scroll_list
@onready var maps = $maps
@onready var map_name = $map_name
@onready var arrow_right = $arrow_right
@onready var arrow_left = $arrow_left

var timer := Timer.new()

var map_node : Node 

var audio_player := AudioStreamPlayer.new()

var map_index : int = 0

var player_ref : Node
var owned_maps : Array[String]



func close():
	queue_free()

func _ready():
	timer.one_shot = true
	add_child(timer)
	player_ref = get_tree().get_first_node_in_group("player")
	owned_maps = player_ref.get_owned_maps()
	var map_name : String = owned_maps[map_index]
	set_map(map_name)
	audio_player.bus = "Effects"
	add_child(audio_player)

func set_map(name : String):
	if(map_node != null):
		map_node.visible = false
	map_node = maps.find_child(name)
	scroll_list.set_map(map_node)
	map_node.visible = true
	map_name.parse_bbcode(name)
	if(map_index > 0):
		arrow_left.visible = true
	else:
		arrow_left.visible = false
	if(map_index + 1 < owned_maps.size()):
		arrow_right.visible = true
	else:
		arrow_right.visible = false

func prev_map():
	if(map_index > 0):
		map_index = map_index - 1
		var map_name : String = owned_maps[map_index]
		set_map(map_name)

func next_map():
	if(map_index + 1 < owned_maps.size()):
		map_index = map_index + 1
		var map_name : String = owned_maps[map_index]
		set_map(map_name)

func _physics_process(delta: float) -> void:
	if(timer.is_stopped()):
		var step : float = 0.15
		if(Input.is_action_pressed("menu_up")):
			scroll_list.decrement_selected()
			timer.start(step)
		if(Input.is_action_pressed("menu_down")):
			scroll_list.increment_selected()
			timer.start(step)
		if(Input.is_action_pressed("menu_left")):
			prev_map()
			timer.start(step)
		if(Input.is_action_pressed("menu_right")):
			next_map()
			timer.start(step)
