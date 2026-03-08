@tool
extends Node2D

@onready var _fade_to_black = $fade_to_black

var fader : Node = null
var teleport_fader = preload("res://entities/util/teleport_fader.tscn")
var prune_node = preload("res://entities/util/prune_node.tscn")

@export var linked_teleporter:Node2D = null
@export var enter_y_push = 0
@export var exit_y_push = 0
@export var exit_only = false
@export var reparent_to_daylight = false
@export var reparent_to_no_daylight = false
@export var reparent_to_dark_indoor = false
@export var secs_for_control_back : int = 0
@export var fade_color : Color = Color(0,0,0)
@export var no_ui_interact = false
@export var inactive : bool = false
@export var no_light_interact = false
@export var turn_off_light = false
@export var remove_held_items = false


@export var scripts_on_enter : Array[Node] = []
@export var scripts_on_exit : Array[Node] = []

@export var adds_and_removes_nodes : bool = false 

@export var add_enter_nodes_parent_map : Array[Node] = []
@export var add_nodes_on_enter : Array[Node] = []
@export var remove_nodes_on_enter : Array[Node] = []
@export var add_nodes_on_exit : Array[Node] = []
@export var add_exit_nodes_parent_map : Array[Node] = []
@export var remove_nodes_on_exit : Array[Node] = []
@export var remove_nodes_on_ready: bool = false
@export var remove_wait : float = 2.0

var run_enter_scripts = false
var run_exit_scripts = false
var entering = false
var loading = false
var exiting = false

var fade_alpha = 0.0
var fade_step = 0.02

var fade_step_secs = 0.006
var teleport_step_secs = 0.5
var timer_fade := Timer.new()
var timer_load_in := Timer.new()

var teleport_load_in_secs = 2.0

#for locking player control during teleport
var timer_control_back := Timer.new() 
var control_timer_active = false 

var player_ref = null

var day_light_ysort : Node
var flat_light_ysort : Node
var dark_ysort : Node

var day_light_layer : Node
var flat_light_layer : Node
var dark_layer : Node

@export var exit_dir : String = ""

var npcs_using_teleporter : Array[Node] = []

var camera_ref

var becomes_inactive_after_teleport : bool = false

func get_fade_color():
	return fade_color

# Called when the node enters the scene tree for the first time.
func _ready():
	player_ref = get_tree().get_first_node_in_group("player")
	day_light_ysort = get_tree().get_first_node_in_group("daylight_affected_ysort")
	flat_light_ysort = get_tree().get_first_node_in_group("no_daylight_ysort")
	dark_ysort = get_tree().get_first_node_in_group("dark_indoor_ysort")
	day_light_layer = get_tree().get_first_node_in_group("daylight_layer")
	flat_light_layer = get_tree().get_first_node_in_group("flat_light_layer")
	dark_layer = get_tree().get_first_node_in_group("dark_layer")
	timer_fade.one_shot = true
	timer_control_back.one_shot = true
	timer_load_in.one_shot = true
	add_child(timer_load_in)
	add_child(timer_fade)
	add_child(timer_control_back)
	camera_ref = get_tree().get_first_node_in_group("camera")
	if(adds_and_removes_nodes && remove_nodes_on_ready):
		remove_nodes(remove_nodes_on_exit)
		remove_nodes(remove_nodes_on_enter)

func is_entering():
	return entering

func set_entering(value : bool):
	entering = value

func is_exiting():
	return exiting

func set_exiting(value : bool):
	exiting = value

func is_control_timer_active():
	return control_timer_active
	
func set_control_timer_inactive():
	control_timer_active = false

func is_loading():
	return loading

func set_loading(value : bool):
	loading = value

func timer_control_back_is_stopped():
	return timer_control_back.is_stopped()

func set_fade_to_black_location(loc : Vector2):
	_fade_to_black.global_position = loc

#func _draw():
	#if(linked_teleporter != null && Engine.is_editor_hint()):
		#draw_line(Vector2(), get_transform().affine_inverse() * linked_teleporter.global_position, Color(0,0,1,1), -1)

func load_wait():
	if(timer_load_in.is_stopped()):
		linked_teleporter.timer_fade.start(teleport_step_secs)
		loading = false
		exiting = true
		#player_ref.get_camera_ref().fade_in(0.1)

func make_active():
	inactive = false

func make_inactive():
	inactive = true

func add_nodes(nodes_list : Array[Node], parent_map : Array[Node]):
	var index : int = 0
	for node in nodes_list:
		var parent = parent_map[index]
		if(node.get_parent() != parent):
			parent.add_child(node)

func remove_nodes(nodes_list : Array[Node]):
	for node in nodes_list:
		if(node.get_parent() != null):
			var parent = node.get_parent()
			var pruner = prune_node.instantiate()
			var node_array : Array[Node] = [node]
			pruner.set_prune_nodes_and_parent(node_array,parent)
			pruner.launch(remove_wait)

func enter():
	if(scripts_on_enter != null && run_enter_scripts):
		for script in scripts_on_enter:
			script.run_script()
	if(adds_and_removes_nodes):
		add_nodes(add_nodes_on_enter, add_enter_nodes_parent_map)
		remove_nodes(remove_nodes_on_enter)
	if(fade_alpha < 1 && timer_fade.is_stopped()):
		fade_alpha = fade_alpha + fade_step
		timer_fade.start(fade_step_secs)
	else: if(fade_alpha >= 1):
		fade_alpha = 1
		player_ref.global_position = linked_teleporter.global_position
		if(remove_held_items):
			player_ref.put_down_and_return()
		if(reparent_to_daylight):
			player_ref.reparent(day_light_ysort)
			if(turn_off_light):
				player_ref.turn_light_off()
			if(!no_light_interact):
				player_ref.turn_light_off()
			day_light_layer.visible = true
			dark_layer.visible = false
			#flat_light_layer.visible = false
		elif(reparent_to_no_daylight):
			if(turn_off_light):
				player_ref.turn_light_off()
			if(!no_light_interact):
				player_ref.turn_light_off()
			day_light_layer.visible = false
			dark_layer.visible = false
			flat_light_layer.visible = true
			player_ref.reparent(flat_light_ysort)
		elif(reparent_to_dark_indoor):
			player_ref.reparent(dark_ysort)
			if(turn_off_light):
				player_ref.turn_light_off()
			if(!no_light_interact):
				player_ref.turn_light_on()
			day_light_layer.visible = false
			dark_layer.visible = true
			#flat_light_layer.visible = false	
		player_ref.stop()
		if(linked_teleporter.exit_y_push != 0):
			player_ref.set_current_v(Vector2(0,linked_teleporter.exit_y_push))
		linked_teleporter.begin_loading()
		entering = false

func begin_loading():
	loading = true
	timer_load_in.start(teleport_load_in_secs)

func exit():
	if(scripts_on_exit != null && run_exit_scripts):
		for script in scripts_on_exit:
			script.run_script()
	if(adds_and_removes_nodes):
		add_nodes(add_nodes_on_exit, add_exit_nodes_parent_map)
		remove_nodes(remove_nodes_on_exit)
	if(fade_alpha > 0 && timer_fade.is_stopped()):
		if(exit_dir != ""):
			player_ref.face_dir(exit_dir)
		fade_alpha = fade_alpha - fade_step
		update_fade_alpha()
		timer_fade.start(fade_step_secs)
	else: if(fade_alpha <= 0):
		fade_alpha = 0
		exiting = false
		#player_ref.stop()
		if(!control_timer_active && secs_for_control_back > 0):
			control_timer_active = true
			timer_control_back.start(secs_for_control_back)
		else:
			#detach_fader()
			player_ref.set_control_frozen(false)
			if(!no_ui_interact):
				player_ref.main_ui_visible()
			detach_fader()
			linked_teleporter.detach_fader()


func attach_fader():
	fader = teleport_fader.instantiate()
	add_child(fader)

func detach_fader():
	if(fader != null):
		fader.queue_free()

func update_fade_alpha():
	_fade_to_black.color = Color(fade_color.r,fade_color.g,fade_color.b,fade_alpha)
	if(linked_teleporter != null):
		linked_teleporter._fade_to_black.color = Color(fade_color.r,fade_color.g,fade_color.b,fade_alpha)
		linked_teleporter.fade_alpha = fade_alpha

func teleport_player():
	attach_fader()
	linked_teleporter.attach_fader()
	entering = true
	run_enter_scripts = true
	linked_teleporter.run_exit_scripts = true
	#attach_fader()
	#player_ref.get_camera_ref().fade_out(0.1)
	player_ref.stop()
	player_ref.set_control_frozen(true)
	#player_ref.disable_collision()
	if(!no_ui_interact):
		player_ref.main_ui_invisible()
	update_fade_alpha()
	timer_fade.start(fade_step_secs)
	var push_vector = Vector2(0,0)
	var horizontal_push_force = 5000
	if(enter_y_push != 0):
		if(enter_y_push > 0):
			push_vector = push_vector + Vector2(0,40000)
		else:
			push_vector = push_vector + Vector2(0,-40000)
	if(player_ref.global_position.x < global_position.x):
		var force_quot = ((global_position.x - player_ref.global_position.x)/16)
		var force = horizontal_push_force * force_quot
		push_vector = push_vector + (Vector2.RIGHT * force)
	elif(player_ref.global_position.x > global_position.x):
		var force_quot = ((player_ref.global_position.x - global_position.x)/16)
		var force = horizontal_push_force * force_quot
		push_vector = push_vector + (Vector2.LEFT * force)
		
	player_ref.set_current_v(push_vector)

func _on_area_2d_body_exited(body):
	if(body in npcs_using_teleporter):
		npcs_using_teleporter.remove_at(npcs_using_teleporter.find(body))

func _on_area_2d_body_entered(body):
	if(not inactive):
		if(body.is_in_group("player")):
			if(!entering && !loading && !exiting && !exit_only):
				teleport_player()
		elif(body.is_in_group("npc") && 
		npcs_using_teleporter.find(body) < 0 &&
		linked_teleporter.npcs_using_teleporter.find(body) < 0):
			npcs_using_teleporter.append(body)
			linked_teleporter.npcs_using_teleporter.append(body)
			body.global_position = linked_teleporter.global_position
			if(reparent_to_daylight):
				body.reparent(day_light_ysort)
			if(reparent_to_no_daylight):
				body.reparent(flat_light_ysort)
			if(reparent_to_dark_indoor):
				body.reparent(dark_ysort)
