extends Camera2D

@onready var _fade_to_black = $fade_to_black
@onready var _flashlight = $flash_light
@onready var _flashlight2 = $flash_light2
@onready var _flashlight3 = $flash_light3

var player_ref

const pan_x_max = 96
const pan_y_max = 96
var pan_timer := Timer.new()
var pan_step = 4
const pan_step_time_secs = 0.005
var camera_offset = Vector2(0,0)
var locked = true

var fading_out = false
var fade_step_secs = 0.05
var timer_fade := Timer.new()
var fade_alpha = 0.0
var fade_step_default = 0.05
var fade_step = fade_step_default

var current_zoom_level = 1.0
var target_zoom_level = 1.0
var timer_zoom := Timer.new()
var zoom_step = 0.002
var zoom_step_secs = 0.001

var player_connected = false

var shake_amount : int = 0
var shaking : bool = false
var shake_left : bool = false
var shake_timer := Timer.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	if(get_parent().is_in_group("player")):
		#this is for debugging and testing.
		#camera will automatically connect, bypassing
		#the game start sequence in root_manager which
		#usually handles this
		get_parent().connect_camera()
	_flashlight.enabled = false
	_flashlight2.enabled = false
	_flashlight3.enabled = false
	pan_timer.one_shot = true
	timer_fade.one_shot = true
	timer_zoom.one_shot = true
	shake_timer.one_shot = true
	add_child(pan_timer)
	add_child(timer_fade)
	add_child(timer_zoom)
	add_child(shake_timer)
	pan_timer.start(pan_step_time_secs)
	timer_fade.start(fade_step_secs)
	fade_alpha = 1
	update_fade_alpha()

func get_pan_y_max() -> float:
	return pan_y_max

func get_pan_x_max() -> float:
	return pan_x_max

func shake(magnitude : int):
	shaking = true
	shake_amount = magnitude

func toggle_flashlight():
	_flashlight.enabled = !_flashlight.enabled

func turn_on_flashlight():
	_flashlight.enabled = true
	
func turn_off_flashlight():
	_flashlight.enabled = false

func is_faded_out() -> bool:
	if(fade_alpha >= 1.0):
		return true
	else:
		return false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	_flashlight.position = camera_offset
	update_fade_alpha()
	if(not locked):
		handle_camera_pan()
		handle_zoom()
		handle_shake()

func zoom_to(level : float):
	target_zoom_level = level
	timer_zoom.start(zoom_step_secs)

func lock():
	locked = true

func unlock():
	locked = false

func fade_out(in_fade_step : float = fade_step_default):
	fade_step = in_fade_step
	fading_out = true

func fade_in(in_fade_step : float = fade_step_default):
	fade_step = in_fade_step
	fading_out = false 

func connect_player(input : Node):
	player_ref = input
	reparent(player_ref)
	offset = position
	position = Vector2(0,0)
	player_connected = true

func connect_anchor(anchor : Node):
	reparent(anchor)
	position = Vector2(0,0)

func update_fade_alpha():
	if(fading_out && timer_fade.is_stopped() && fade_alpha < 1):
		fade_alpha = fade_alpha + fade_step
		timer_fade.start(fade_step_secs)
	elif(!fading_out && timer_fade.is_stopped() && fade_alpha > 0):
		fade_alpha = fade_alpha - fade_step
		timer_fade.start(fade_step_secs)
	_fade_to_black.color = Color(0,0,0,fade_alpha)

func handle_zoom():
	zoom.x = current_zoom_level
	zoom.y = current_zoom_level
	if(target_zoom_level != current_zoom_level):
		if(timer_zoom.is_stopped()):
			if(target_zoom_level < current_zoom_level):
				current_zoom_level = current_zoom_level - zoom_step
			elif(target_zoom_level > current_zoom_level):
				current_zoom_level = current_zoom_level + zoom_step
			if(target_zoom_level <= current_zoom_level + zoom_step &&
			target_zoom_level >= current_zoom_level - zoom_step):
				current_zoom_level = target_zoom_level
			else:
				timer_zoom.start(zoom_step_secs)

func handle_shake():
	if(shaking):
		if(shake_timer.is_stopped()):
			var drag_margin = 32
			var amount = drag_margin + shake_amount
			if(shake_left):
				position = Vector2(-amount,0)
			else:
				position = Vector2(amount,0)
			shake_left = !shake_left
			shake_amount = shake_amount - 1
			if(shake_amount <= 0):
				shaking = false
				position = Vector2(0,0)
			shake_timer.start(0.05)

func handle_camera_pan():
	var pan_direction = Input.get_vector("pan_left", "pan_right", "pan_up", "pan_down")
	if(player_ref.dialog_panning):
		pan_direction = Vector2(0,-1)
	if(player_ref.dead):
		pan_direction = Vector2(0,0)
	
	#add dead zone for joysticks
	if(pan_direction.x < 0.4 && pan_direction.x > -0.4):
		pan_direction.x = 0
	if(pan_direction.y < 0.4 && pan_direction.y > -0.4):
		pan_direction.y = 0
		
	if(pan_timer.is_stopped()):
		var destination_x = (pan_direction.x/abs(pan_direction.x)) * pan_x_max 
		var destination_y = (pan_direction.y/abs(pan_direction.y)) * pan_y_max
		#var max_vector = Vector2(pan_x_max,pan_y_max)
			
		var adj_x_step = pan_step
		var adj_y_step = pan_step
		var divisor = 3
		var x_edge = pan_x_max / divisor
		var y_edge = pan_x_max / divisor
		var edge_x_distance = pan_x_max - abs(camera_offset.x)
		var edge_y_distance = pan_y_max - abs(camera_offset.y)
		
		if(edge_x_distance < x_edge):
			adj_x_step = (abs(edge_x_distance)/x_edge) * pan_step
		if(edge_y_distance < y_edge):
			adj_y_step = (abs(edge_y_distance)/y_edge) * pan_step
			
		var ret_adj_x_step = pan_step
		var ret_adj_y_step = pan_step
		if(abs(camera_offset.x) < x_edge):
			ret_adj_x_step = ceil((abs(camera_offset.x)/x_edge) * pan_step)
		if(abs(camera_offset.y) < y_edge):
			ret_adj_y_step = ceil((abs(camera_offset.y)/y_edge) * pan_step)
			
		#pan x
		if(destination_x > 0):
			if(camera_offset.x < destination_x):
				camera_offset = camera_offset + Vector2(adj_x_step,0)
		elif(destination_x < 0):
			if(camera_offset.x > destination_x):
				camera_offset = camera_offset + Vector2(-adj_x_step,0)
			
		#return x to center
		if(pan_direction.x == 0):
			if(camera_offset.x > 0):
				camera_offset = camera_offset + Vector2(-ret_adj_x_step,0)
			elif(camera_offset.x < 0):
				camera_offset = camera_offset + Vector2(ret_adj_x_step,0)
				
		#pan y
		if(destination_y > 0):
			if(camera_offset.y < destination_y):
				camera_offset = camera_offset + Vector2(0,adj_y_step)
		elif(destination_y < 0):
			if(camera_offset.y > destination_y):
				camera_offset = camera_offset + Vector2(0,-adj_y_step)
				
		#return y to center
		if(pan_direction.y == 0):
			if(camera_offset.y > 0):
				camera_offset = camera_offset + Vector2(0,-ret_adj_y_step)
			elif(camera_offset.y < 0):
				camera_offset = camera_offset + Vector2(0,ret_adj_y_step)
			
			#snap to center
		if(pan_direction.x == 0 &&
		camera_offset.x < 1 && 
		camera_offset.x > -1):
			camera_offset.x = 0
		if(pan_direction.y == 0 &&
		camera_offset.y < 1 && 
		camera_offset.y > -1):
			camera_offset.y = 0
			
		pan_timer.start(pan_step_time_secs)
		
	set_offset(camera_offset)
