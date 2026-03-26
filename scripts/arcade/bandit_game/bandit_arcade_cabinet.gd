extends Node2D

var ui = preload("res://arcade/bandit_arcade_game/bandit_arcade_machine.tscn")


#0 = daylight
#1 = indoors
#2 = dark
@export var layer_index = 0

@export var bandit_spawn : Node
@export var spawn1 : Node
@export var spawn2 : Node
@export var spawn3 : Node
@export var spawn4 : Node
@export var spawn5 : Node

@export var doors : Array[Node]

@export var home_team_blu : bool = false

var ui_ref = null
var ui_active = false

var player_ref = null

var timer := Timer.new()

var exiting = false

func _ready() -> void:
	timer.one_shot = true
	add_child(timer)

func get_layer_index():
	return layer_index

var cost : int = 5
var fading = false

func set_up_ui():
	if(player_ref != null):
		if(home_team_blu):
			ui_ref.set_home_team_blu()
		ui_ref.set_layer_index(layer_index)
		var spawns : Array[Node] = [spawn1,spawn2,spawn3,spawn4,spawn5]
		ui_ref.set_spawns(bandit_spawn,spawns)
		ui_ref.set_doors(doors)
		ui_ref.set_cabinet_ref(self)

func interact():
	if(timer.is_stopped()):
		player_ref = get_tree().get_first_node_in_group("player")
		if(player_ref.get_money() >= cost):
			player_ref.set_money(player_ref.get_money() - cost)
			fading = true
			var camera_ref = get_tree().get_first_node_in_group("camera")
			camera_ref.fade_out()
			timer.start(2)

func exit_ui():
	ui_active = false
	ui_ref.clean_up()
	var camera_ref = player_ref.get_camera_ref()
	camera_ref.fade_in()

func end_game():
	var camera_ref = get_tree().get_first_node_in_group("camera")
	camera_ref.fade_out()
	timer.start(2)
	exiting = true

func _physics_process(delta: float) -> void:
	if(ui_active):
		ui_ref.global_position = player_ref.get_camera_ref().get_screen_center_position()
		if Input.is_action_just_pressed("use_item"):
			end_game()
	if(timer.is_stopped()):
		if(fading):
			fading = false
			ui_ref = ui.instantiate()
			player_ref.set_control_frozen(true)
			player_ref.main_ui_invisible()
			ui_ref.global_position = player_ref.get_camera_ref().get_screen_center_position()
			set_up_ui()
			var no_daylight_ysort = get_tree().get_first_node_in_group("no_daylight_ysort")
			no_daylight_ysort.add_child(ui_ref)
			ui_active = true
			ui_ref.start_game()
			var camera_ref = get_tree().get_first_node_in_group("camera")
			camera_ref.fade_in()
		if(exiting):
			ui_ref.reset_camera()
			exit_ui()
			var camera_ref = get_tree().get_first_node_in_group("camera")
			camera_ref.fade_in()
			exiting = false
			player_ref.set_control_frozen(false)
			player_ref.main_ui_visible()
