@tool
extends RigidBody2D

@onready var _character_base = $character_base
@onready var _grabber = $grabber
@onready var _tough_luck = $tough_luck
@onready var _collision = $CollisionShape2D
@onready var _ui = $ui_canvas/player_ui
@onready var _light = $player_light
@onready var _flash_light = $flash_light

var _camera
var camera_connected = false

@export var base_spriteframes : SpriteFrames
@export var hat_spriteframes : SpriteFrames
@export var top_spriteframes : SpriteFrames
@export var bottom_spriteframes : SpriteFrames
@export var facing_dir = "right"

var no_clip = false
var dev_zoom = false
const no_clip_speed = 3200000

var player_die = preload("res://entities/characters/player/player_die.tscn") 
var dash_get = preload("res://interface/dash_get.tscn")
var die_material = preload("res://entities/characters/player/die_material.tres")
var speech_bubble = preload("res://dialog/speech_bubble.tscn")
var player_material = preload("res://entities/characters/player/player_material.tres")

var sound_player := AudioStreamPlayer.new()

const normal_speed = 50000
const dash_speed = 100000
var acceleration_quotient = normal_speed
const top_speed = 180

var current_dash_secs : float = 0.0
var max_dash_secs : float = 20.0
var full_dash_secs : float = 60.0

var can_dash = true
var is_dashing = false
var dash_time_secs = 0.5
var dash_regen_time_secs = 5
var timer_dash := Timer.new()
var timer_dash_regen := Timer.new()

var in_dialog = false
var dialog_panning = false

var holding_object = false
var will_grab_object = null
var grabbed_object = null
var control_frozen = false
var current_v = Vector2(0,0)

const full_max_hp = 6
const max_hp = 2
var current_hp = 2
var is_invincible = false
var invincibility_timer := Timer.new()
var damage_collision_layer = 13

var dead = false

var speech_instance = null
var comment_timer := Timer.new()
var comment_timer_wait_secs = 1
var comment_waiting = false

var anchored = false
var active_anchor : Node = null

var money : int = 0

var light_on = false
var has_flashlight = false

var dev_occlusion_enabled = true

func _ready():
	_collision.disabled = no_clip
	timer_dash.one_shot = true
	timer_dash_regen.one_shot = true
	invincibility_timer.one_shot = true
	
	comment_timer.one_shot = true
	sound_player.bus = "Effects"
	add_child(sound_player)
	add_child(timer_dash)
	add_child(timer_dash_regen)
	add_child(invincibility_timer)
	add_child(comment_timer)
	
	#set up character base
	_character_base.set_facing_dir(facing_dir)
	_character_base.set_spriteframes(base_spriteframes,
	hat_spriteframes,
	top_spriteframes,
	bottom_spriteframes)
	
	_ui.set_max_hearts(max_hp)
	current_dash_secs = max_dash_secs
	update_max_dash_meter()
	
	_light.enabled = false
	_flash_light.enabled = false
	
	if(Engine.is_editor_hint()):
		queue_redraw()

func get_hat_spriteframes() -> SpriteFrames:
	return hat_spriteframes

func get_top_spriteframes() -> SpriteFrames:
	return top_spriteframes

func get_bottom_spriteframes() -> SpriteFrames:
	return bottom_spriteframes

func set_hat_spriteframes(hat : SpriteFrames):
	_character_base.set_hat_spriteframes(hat)

func set_top_spriteframes(top : SpriteFrames):
	_character_base.set_top_spriteframes(top)

func set_bottom_spriteframes(bottom : SpriteFrames):
	_character_base.set_bottom_spriteframes(bottom)

func set_ui_visible():
	_ui.visible = true

func set_ui_invisible():
	_ui.visible = false

func enter_dialog():
	stop()
	control_frozen = true
	dialog_panning = true
	in_dialog = true

func update_max_dash_meter():
	_ui.set_max_dash_fraction(max_dash_secs / full_dash_secs)

func update_dash_meter():
	update_max_dash_meter()
	_ui.set_dash_fraction(current_dash_secs / max_dash_secs)

func show_dash():
	update_dash_meter()
	_ui.show_dash()

func hide_dash():
	_ui.hide_dash()

func turn_light_on():
	light_on = true
	if(has_flashlight):
		_flash_light.enabled = true
	else:
		_light.enabled = true

func turn_light_off():
	light_on = false
	if(has_flashlight):
		_flash_light.enabled = false
	else:
		_light.enabled = false

func show_hearts():
	_ui.show_hearts()

func hide_hearts():
	_ui.hide_hearts()

func show_money():
	_ui.show_money()

func hide_money():
	_ui.hide_money()
	
func connect_camera():
	_camera = get_tree().get_first_node_in_group("camera")
	_camera.connect_player(self)
	camera_connected = true
	_camera.unlock()

func exit_dialog():
	in_dialog = false
	control_frozen = false
	dialog_panning = false

func get_money():
	return money

func anchor(anchor : Node):
	_collision.disabled = true
	control_frozen = true
	anchored = true
	active_anchor = anchor

func disable_anchor():
	_collision.disabled = false
	control_frozen = false
	anchored = false
	active_anchor = null

func _on_add_money(num : int):
	var new_money = money + num
	if(new_money < 0):
		new_money = 0
		
	set_money(new_money)

func _on_pizza_lost():
	_ui._on_pizza_lost()

func set_money(num : int):
	money = num
	_ui.set_money(money)

func go_invincible():
	invincibility_timer.start(1.5)
	_character_base.start_flashing()
	is_invincible = true
	set_collision_layer_value(damage_collision_layer,false)

func go_vincible():
	_character_base.stop_flashing()
	is_invincible = false
	set_collision_layer_value(damage_collision_layer,true)

func face_dir(dir : String):
	if (dir == direction.right):
		_character_base.face_right()
	else: if (dir == direction.left):
		_character_base.face_left()
	else: if (dir == direction.up):
		_character_base.face_up()
	else: if (dir == direction.down):
		_character_base.face_down()

func _activate_location_header(name : String):
	_ui.activate_header(name)

func get_input():
	if(!control_frozen):
		#orient and player according to input
		if Input.is_action_pressed(direction.right):
			_character_base.face_right()
		else: if Input.is_action_pressed(direction.left):
			_character_base.face_left()
		else: if Input.is_action_pressed(direction.up):
			_character_base.face_up()
		else: if Input.is_action_pressed(direction.down):
			_character_base.face_down()
		handle_interact()
		handle_throw()
		handle_dash()
		handle_dev()
		move()

func handle_dev():
	if Input.is_action_just_pressed("dev_no_clip"):
		if(no_clip):
			no_clip = false
			acceleration_quotient = normal_speed
			_collision.disabled = false
		else:
			no_clip = true
			acceleration_quotient = no_clip_speed
			_collision.disabled = true
	if Input.is_action_just_pressed("dev_toggle_zoom"):
		if(camera_connected):
			if(dev_zoom == false):
				dev_zoom = true
				_camera.zoom_to(0.2)
			else:
				dev_zoom = false
				_camera.zoom_to(1.0)
	if Input.is_action_just_pressed("dev_toggle_occluders"):
		var occluders = get_tree().get_nodes_in_group("visual_occluder")
		if(dev_occlusion_enabled):
			dev_occlusion_enabled = false
			for occluder in occluders:
				occluder.occluding_enabled = false
		else:
			dev_occlusion_enabled = true
			for occluder in occluders:
				occluder.occluding_enabled = true

func get_current_hp():
	return current_hp

func heal_hp(heal):
	if (current_hp <  max_hp):
		if current_hp + heal > max_hp:
			current_hp = max_hp
		else:
			current_hp = current_hp + heal

func increment_hp():
	if(current_hp < max_hp):
		current_hp = current_hp + 1
		_ui.update_hearts(current_hp)

func reduce_hp():
	current_hp = current_hp - 1
	_ui.update_hearts(current_hp)
	if(current_hp == 0):
		_character_base.stop_flashing()
		die()
	else:
		go_invincible()

func _on_body_entered(body:Node):
	if(body.is_in_group("bullet")):
		reduce_hp()

func _on_make_comment(text : String):
	if(speech_instance != null):
		speech_instance.queue_free()
	speech_instance = speech_bubble.instantiate()
	self.add_child(speech_instance)
	speech_instance.play_passive_text(text, "sine_voice")
	comment_timer.start(comment_timer_wait_secs)
	comment_waiting = false

func die():
	if(!dead):
		control_frozen = true
		_ui.visible = false
		var die_guy = player_die.instantiate()
		_character_base.reparent(die_guy)
		die_guy.position = position
		_character_base.global_position = die_guy.global_position
		_character_base.set_all_materials(die_material)
		get_parent().add_child(die_guy)
		visible = false
		die_guy.start_dyin(_character_base.get_facing_dir())
		dead = true

func resurrect():
	if(dead):
		control_frozen = false
		_ui.visible = true
		_character_base.reparent(self)
		_character_base.global_position = global_position
		_character_base.set_all_materials(player_material)
		var spawn_point = get_tree().get_first_node_in_group("player_spawn")
		global_position = spawn_point.global_position
		visible = true
		var die_guy = get_tree().get_first_node_in_group("dead_player")
		die_guy.queue_free()
		dead = false
		current_hp = 3

func handle_interact():
	if Input.is_action_just_pressed("interact"):
			if(_grabber.is_colliding()):
					var grabObj = _grabber.get_collider(0)
					if(grabObj.is_in_group("interactable")):
						grabObj.interact()
			handle_pick_up()

func handle_dash():
	if Input.is_action_just_pressed("dash"):
		dash()
	elif Input.is_action_just_released("dash"):
		stop_dash()

func give_dash_seconds(seconds):
	if(current_dash_secs < max_dash_secs):
		if(current_dash_secs + seconds >= max_dash_secs):
			current_dash_secs = max_dash_secs
		else:
			current_dash_secs = current_dash_secs + seconds

func give_dash_fraction(fraction: float):
	give_dash_seconds(max_dash_secs * fraction)

func handle_throw():
	if Input.is_action_just_pressed("throw"):
		throw()

func set_control_frozen(value):
	control_frozen = value

func set_current_v(vect : Vector2):
	current_v = vect

func stop():
	current_v = Vector2(0,0)

func set_holding_object(is_holding):
	holding_object = is_holding
	_character_base.set_arms_raised(is_holding)

func throw():
	if(holding_object):
		sound_player.stream = load("res://audio/soundFX/woosh.wav")
		sound_player.play()
		grabbed_object.throw(_character_base.get_facing_dir())
		grabbed_object = null
		set_holding_object(false)

func handle_pick_up():
	if(will_grab_object != null && !holding_object):
		sound_player.stream = load("res://audio/soundFX/pickup.wav")
		sound_player.play()
		will_grab_object.pick_up(self)
		grabbed_object = will_grab_object
		set_holding_object(true)
	else: if(holding_object):
		sound_player.stream = load("res://audio/soundFX/putdown.wav")
		sound_player.play()
		grabbed_object.put_down(_character_base.get_facing_dir())
		grabbed_object = null
		set_holding_object(false)

func return_pizza():
	sound_player.stream = load("res://audio/soundFX/pickup.wav")
	sound_player.play()
	var pizza = get_tree().get_first_node_in_group("pizza")
	pizza.pick_up(self)
	grabbed_object = pizza
	set_holding_object(true)

func stop_dash():
	if(is_dashing):
		is_dashing = false
		_camera.zoom_to(1.0)
		_ui.dash_stop_blink()

func dash():
	if(!is_dashing && Input.get_vector(direction.left, direction.right, direction.up, direction.down).length() > 0):
		if(current_dash_secs > 0):
			sound_player.stream = load("res://audio/soundFX/woosh.wav")
			sound_player.play()
			is_dashing = true
			timer_dash.start(1)
			_camera.zoom_to(1.25)
			_ui.dash_blink()

func speed():
	return linear_velocity.length()

func update_grabber():
	match(_character_base.get_facing_dir()):
		direction.right:
			_grabber.set_rotation_degrees(270) 
		direction.left:
			_grabber.set_rotation_degrees(90)
		direction.up:
			_grabber.set_rotation_degrees(180)
		direction.down:
			_grabber.set_rotation_degrees(0)

func move():
	var input_direction = Input.get_vector(direction.left, direction.right, direction.up, direction.down)
	
	#accelerate if we have't hit max
	if(input_direction.length() != 0 && speed() < top_speed):
		current_v = input_direction * acceleration_quotient 
	else: 
		current_v = input_direction * 0
	
	_character_base.set_animation_scale(0.2, 0.8, speed(), top_speed)

#func _process(_delta):
	#if(!Engine.is_editor_hint()):
		
					
func _physics_process(delta):
	if(!Engine.is_editor_hint()):
		if(camera_connected):
			_camera.handle_camera_pan()
		if(!dead):
			get_input()
			if(in_dialog):
				current_v = Vector2(0,0)
			apply_force(current_v)
			if(invincibility_timer.is_stopped() &&
			is_invincible == true):
				go_vincible()
			_ui.update_hearts(current_hp)
			_ui.set_money(money)
			if(anchored && active_anchor != null):
				global_position = active_anchor.global_position

			_character_base.animate_sprite_by_vector(current_v, (speed() >= top_speed))
			update_grabber()
			will_grab_object = null
			#check grabber for pick-upable objects
			if(!holding_object):
				var grabObj = null
				
				if(_grabber.is_colliding()):
					grabObj = _grabber.get_collider(0)
				
				#check for pickupables
				get_tree().call_group("pickupable", "set_will_pickup_false")
				if(grabObj != null && 
				grabObj.is_in_group("pickupable")):
					grabObj.will_pickup = true
					will_grab_object = grabObj
			#stop dash if meter is depleted
			update_dash_meter()
			if(is_dashing):
				acceleration_quotient = dash_speed
				if(timer_dash.is_stopped()):
					current_dash_secs = current_dash_secs - 1
					if(current_dash_secs <= 0):
						stop_dash()
					else:
						timer_dash.start(1)
			else:
				if(!no_clip):
					acceleration_quotient = normal_speed
				else:
					acceleration_quotient = no_clip_speed
			
			#regen dash
			#if(timer_dash_regen.is_stopped() && can_dash == false && !is_dashing):
				#sound_player.stream = load("res://audio/soundFX/dashget.wav")
				#sound_player.play()
				#can_dash = true
				#add_child(dash_get.instantiate())
			
			if(speech_instance != null &&
			speech_instance.full_text_displayed):
				if(!comment_waiting):
					comment_timer.start(comment_timer_wait_secs)
					comment_waiting = true
				else:
					if(comment_timer.is_stopped()):
						speech_instance.queue_free()
		
