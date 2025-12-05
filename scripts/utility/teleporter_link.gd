@tool
extends Node2D

@onready var _fade_to_black = $fade_to_black
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

func _draw():
	if(linked_teleporter != null && Engine.is_editor_hint()):
		draw_line(Vector2(), get_transform().affine_inverse() * linked_teleporter.global_position, Color(0,0,1,1), -1)

func _process(delta):
	if(entering || exiting || control_timer_active):
		update_fade_alpha()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if(entering || exiting || loading ||  control_timer_active):
		_fade_to_black.global_position = Vector2(0,0)
		if(Engine.is_editor_hint()):
			queue_redraw()
		if(entering):
			enter()
		elif(loading):
			load_wait() # wait for pruned objects to load in
		elif(exiting):
			exit()
		elif(control_timer_active && timer_control_back.is_stopped()):
			control_timer_active = false
			exiting = false
			player_ref.set_control_frozen(false)

func load_wait():
	if(timer_load_in.is_stopped()):
		linked_teleporter.timer_fade.start(teleport_step_secs)
		loading = false
		exiting = true
		#player_ref.get_camera_ref().fade_in(0.1)

func enter():
	if(fade_alpha < 1 && timer_fade.is_stopped()):
		fade_alpha = fade_alpha + fade_step
		timer_fade.start(fade_step_secs)
	else: if(fade_alpha >= 1):
		fade_alpha = 1
		player_ref.global_position = linked_teleporter.global_position
		if(reparent_to_daylight):
			player_ref.reparent(day_light_ysort)
			player_ref.turn_light_off()
			day_light_layer.visible = true
			dark_layer.visible = false
			#flat_light_layer.visible = false
		elif(reparent_to_no_daylight):
			player_ref.turn_light_off()
			day_light_layer.visible = false
			dark_layer.visible = false
			flat_light_layer.visible = true
			player_ref.reparent(flat_light_ysort)
		elif(reparent_to_dark_indoor):
			player_ref.reparent(dark_ysort)
			player_ref.turn_light_on()
			day_light_layer.visible = false
			dark_layer.visible = true
			#flat_light_layer.visible = false	
		player_ref.stop()
		if(linked_teleporter.exit_y_push != 0):
			player_ref.set_current_v(Vector2(0,linked_teleporter.exit_y_push))
		linked_teleporter.is_loading()
		entering = false

func is_loading():
	loading = true
	timer_load_in.start(teleport_load_in_secs)

func exit():
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
			player_ref.set_control_frozen(false)
			if(!no_ui_interact):
				player_ref.main_ui_visible()

func update_fade_alpha():
	_fade_to_black.color = Color(fade_color.r,fade_color.g,fade_color.b,fade_alpha)
	if(linked_teleporter != null):
		linked_teleporter._fade_to_black.color = Color(fade_color.r,fade_color.g,fade_color.b,fade_alpha)
		linked_teleporter.fade_alpha = fade_alpha

func _on_area_2d_body_exited(body):
	if(body in npcs_using_teleporter):
		npcs_using_teleporter.remove_at(npcs_using_teleporter.find(body))

func _on_area_2d_body_entered(body):
	if(body.is_in_group("player")):
		if(!entering && !loading && !exiting && !exit_only):
			entering = true
			#player_ref.get_camera_ref().fade_out(0.1)
			player_ref.stop()
			player_ref.set_control_frozen(true)
			#player_ref.disable_collision()
			if(!no_ui_interact):
				player_ref.main_ui_invisible()
			update_fade_alpha()
			timer_fade.start(fade_step_secs)
			if(enter_y_push != 0):
				player_ref.set_current_v(Vector2(0,enter_y_push))
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
