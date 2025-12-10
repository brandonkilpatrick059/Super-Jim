@tool
extends RigidBody2D

@onready var _character_base = $character_base
@onready var _grabber = $grabber
@onready var _tough_luck = $tough_luck
@onready var _collision = $CollisionShape2D
@onready var _ui_canvas = $ui_canvas
@onready var _ui = $ui_canvas/player_ui
@onready var _light = $player_light
@export var card_deck : Array[int] = []
@export var owned_cards : Array[int] = [0,0,0,0,0,0,0,0,0, #green
										0,0,0,0,0,0,0,0,0, #yellow
										0,0,0,0,0,0,0,0,0, #gray
										0,0,0,0,0,0,0,0,0, #white
										0,0,0,0] #legendaries
var max_each_card = 5

var _camera
var camera_connected = false

@export var base_spriteframes : SpriteFrames
@export var hat_spriteframes : SpriteFrames
@export var top_spriteframes : SpriteFrames
@export var bottom_spriteframes : SpriteFrames
@export var facing_dir = "right"

var no_clip = false
var dev_zoom_level = 0
const no_clip_speed = 3200000

var player_die = preload("res://entities/characters/player/player_die.tscn") 
var card_binder = preload("res://baseball/card_binder.tscn")
var die_material = preload("res://entities/characters/player/die_material.tres")
var speech_bubble = preload("res://dialog/speech_bubble.tscn")
var player_material = preload("res://entities/characters/player/player_material.tres")

var bump_sound = preload("res://audio/soundFX/bigCollide.wav")
var woosh_sound = preload("res://audio/soundFX/woosh.wav")
var dash_sound = preload("res://audio/soundFX/dash.wav")
var pickup_sound = preload("res://audio/soundFX/pickup.wav")
var putdown_sound = preload("res://audio/soundFX/putdown.wav")
var crystal_sound = preload("res://audio/soundFX/crystal_get.wav")

var sound_player := AudioStreamPlayer.new()

var timer_load_in : Timer = Timer.new()
var loading_in : bool = false

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
var dash_regen_secs = 0

var in_dialog = false
var dialog_panning = false #checked by main camera

var holding_object = false
var will_grab_object = null
var grabbed_object = null
var control_frozen = false
var current_v = Vector2(0,0)

const full_max_hp = 6
var max_hp = 2
var current_hp = 2
var is_invincible = false
var invincibility_timer := Timer.new()
var damage_collision_layer = 13

var push_timer := Timer.new()
var push_vector : Vector2 = Vector2(0,0)

var dead = false

var speech_instance = null
var comment_timer := Timer.new()
var comment_timer_wait_secs = 1
var comment_waiting = false

var anchored = false
var active_anchor : Node = null

var money : int = 0
var banked_money : int = 0

var light_on = false

var dev_occlusion_enabled = true

var use_item_timer : Timer = Timer.new()

#TODO: character gen when the game starts to randomly choose some defaults? Let the player choose defaults?
#empty string "" -> default, empty slot. Note bottoms default is pants_0
var hats_index = 0
var tops_index = 0
var bottoms_index = 0
var owned_hats : Array[String] = ["",]
var owned_tops : Array[String] = ["","res://sprites/spritesheets/spriteframes/characters/top/full_sheet/shirt_1.tres","res://sprites/spritesheets/spriteframes/characters/top/full_sheet/shirt_2.tres"]
var owned_bottoms : Array[String] = ["res://sprites/spritesheets/spriteframes/characters/bottom/full_sheet/pants_0.tres","res://sprites/spritesheets/spriteframes/characters/bottom/full_sheet/pants_1.tres"]

var items : Array[String] = []
var item_index : int = 0

var main_ui_hidden = false

#item cosnt
const flashlight : String = "flashlight"
const pizza : String = "pizza"
const cardbinder : String = "card_binder"

func _ready():
	_collision.disabled = no_clip
	timer_dash.one_shot = true
	timer_dash_regen.one_shot = true
	invincibility_timer.one_shot = true
	use_item_timer.one_shot = true
	timer_load_in.one_shot = true
	push_timer.one_shot = true
	
	comment_timer.one_shot = true
	sound_player.bus = "Effects"
	add_child(sound_player)
	add_child(timer_dash)
	add_child(timer_dash_regen)
	add_child(invincibility_timer)
	add_child(comment_timer)
	add_child(use_item_timer)
	add_child(timer_load_in)
	add_child(push_timer)
	
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
	
	if(Engine.is_editor_hint()):
		queue_redraw()

#called when the player loads in from a save
func load_in():
	if(!loading_in):
		loading_in = true
		set_ui_invisible()
		control_frozen = true
		timer_load_in.start(5)
		var time_keeper = get_tree().get_first_node_in_group("time_keeper")
		time_keeper.set_clock(9)
		time_keeper.unlock_time()
		sound_player.stream = load("res://audio/music/sleep theme.wav")
		sound_player.play()

func update_clothes():
	var hat_str : String = owned_hats[hats_index]
	var top_str : String = owned_tops[tops_index]
	var bottom_str : String = owned_bottoms[bottoms_index]
	_character_base.load_and_set_spriteframes()

func set_and_update_cloths(hat : int, top : int, bottom : int):
	hats_index = hat
	tops_index = top
	bottoms_index = bottom
	var hat_str : String = owned_hats[hats_index]
	var top_str : String = owned_tops[tops_index]
	var bottom_str : String = owned_bottoms[bottoms_index]
	_character_base.load_and_set_spriteframes(base_spriteframes.resource_path,hat_str,top_str,bottom_str)

func get_hats_index():
	return hats_index

func get_tops_index():
	return tops_index

func get_bottoms_index():
	return bottoms_index

func set_hats_index(index : int):
	hats_index = index

func set_tops_index(index : int):
	tops_index = index

func set_bottoms_index(index : int):
	bottoms_index = index

func get_owned_hats() -> Array[String]:
	return owned_hats

func get_owned_tops() -> Array[String]:
	return owned_tops

func get_owned_bottoms() -> Array[String]:
	return owned_bottoms

#called when the player starts a new game
func new_game():
	var time_keeper = get_tree().get_first_node_in_group("time_keeper")
	time_keeper.set_clock(10)

func turn_on_ui_noises():
	_ui.turn_on_ui_noises() 

func get_save_dictionary() -> Dictionary:
	var parent_group : String = get_parent().get_groups()[0]
	var hat : String = ""
	if(hat_spriteframes != null):
		hat = hat_spriteframes.resource_path
	var top : String = ""
	if(top_spriteframes != null):
		top = top_spriteframes.resource_path
	var bottom : String = ""
	if(bottom_spriteframes != null):
		bottom = bottom_spriteframes.resource_path
	var save_dictionary = {
		"parent_group" : parent_group,
		"pos_x" : global_position.x,
		"pos_y" : global_position.y,
		"max_hp" : max_hp, 
		"current_dash_secs" : current_dash_secs,
		"max_dash_secs" : max_dash_secs,
		"money" : money,
		"banked_money" : banked_money,
		"base_spriteframes" : base_spriteframes.resource_path,
		"hat_spriteframes" : hat,
		"top_spriteframes" : top,
		"bottom_spriteframes" : bottom,
		"card_deck" : card_deck,
		"owned_cards" : owned_cards,
		"items" : items
	}
	return save_dictionary

func get_base() -> String:
	return base_spriteframes.resource_path

func push(push_vect : Vector2, time_secs : float):
	push_timer.start(time_secs)
	stop()
	push_vector = push_vect

func load_from_dictionary(load_dictionary : Dictionary):
	var parent_group = String(load_dictionary.get("parent_group"))
	var parent = get_tree().get_first_node_in_group(parent_group)
	reparent(parent)
	global_position = Vector2(load_dictionary.get("pos_x"), load_dictionary.get("pos_y"))
	max_hp = int(load_dictionary.get("max_hp"))
	max_dash_secs = load_dictionary.get("max_dash_secs")
	update_max_dash_meter()
	current_dash_secs = load_dictionary.get("current_dash_secs")
	money = int(load_dictionary.get("money"))
	banked_money = load_dictionary.get("banked_money")
	base_spriteframes = load(load_dictionary.get("base_spriteframes"))
	var load_owned_cards = load_dictionary.get("owned_cards")
	var index = 0
	while(index < load_owned_cards.size()):
		owned_cards[index] = int(load_owned_cards[index])
		index = index + 1
	var load_card_deck = load_dictionary.get("card_deck")
	index = 0
	while(index < load_card_deck.size()):
		card_deck.append(int(load_card_deck[index]))
		index = index + 1
	var load_items = load_dictionary.get("items")
	index = 0
	while(index < load_items.size()):
		items.append(String(load_items[index]))
		index = index + 1
	var hat = load_dictionary.get("hat_spriteframes")
	var top = load_dictionary.get("top_spriteframes")
	var bottom = load_dictionary.get("bottom_spriteframes")
	if(hat != ""):
		hat_spriteframes = load(hat)
	if(top != ""):
		top_spriteframes = load(top)
	if(bottom != ""):
		bottom_spriteframes = load(bottom)
	_character_base.set_spriteframes(base_spriteframes,
		hat_spriteframes,
		top_spriteframes,
		bottom_spriteframes)

func set_deck(deck : Array[int]):
	card_deck = deck

func get_deck() -> Array[int]:
	return card_deck

func add_owned_card(card : int):
	if(!items.has(cardbinder)):
		items.append(cardbinder)
	if(owned_cards[card-1] < 5):
		owned_cards[card-1] = owned_cards[card-1] + 1

func get_owned_cards() -> Array[int]:
	return owned_cards

#func increment_owned_card(index : int):
	#if(owned_cards[index] + 1 <= 5):
		#owned_cards[index] = owned_cards[index] + 1
#
#func decrement_owned_card(index : int):
	#if(owned_cards[index] - 1 >= 0):
		#owned_cards[index] = owned_cards[index] - 1

func get_num_card(index : int):
	return owned_cards[index]

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

func get_camera_global_pos():
	var pos = _camera.global_position + _camera.offset
	return pos

func enter_dialog():
	stop()
	control_frozen = true
	is_dashing = false
	dialog_panning = true
	in_dialog = true

func set_dialog_panning(input: bool):
	dialog_panning = input

func update_max_dash_meter():
	_ui.set_max_dash_fraction(max_dash_secs / full_dash_secs)

func update_dash_meter():
	update_max_dash_meter()
	_ui.set_dash_fraction(current_dash_secs / max_dash_secs)

func add_to_max_dash_secs(num : int):
	var new_max_dash_secs = max_dash_secs + num
	if new_max_dash_secs < full_dash_secs:
		max_dash_secs = new_max_dash_secs
	update_dash_meter()
	sound_player.stream = crystal_sound
	sound_player.play()
	_on_make_comment("Cool, a Dash Crystal!")

func show_dash():
	update_dash_meter()
	_ui.show_dash()

func hide_dash():
	_ui.hide_dash()

func turn_light_on():
	_light.enabled = true
	light_on = true

func turn_light_off():
	light_on = false
	_light.enabled = false

func show_hearts():
	_ui.show_hearts()

func hide_hearts():
	_ui.hide_hearts()

func show_money():
	_ui.show_money()

func hide_money():
	_ui.hide_money()

func main_ui_invisible():
	hide_hearts()
	hide_money()
	hide_dash()
	_ui.hide_item_square()
	main_ui_hidden = true

func main_ui_visible():
	show_hearts()
	show_money()
	show_dash()
	_ui.show_item_square()
	main_ui_hidden = false

func connect_camera():
	_camera = get_tree().get_first_node_in_group("camera")
	_camera.connect_player(self)
	camera_connected = true
	_camera.unlock()

func is_in_dialog():
	return in_dialog

func add_scene_to_ui_tree(scene : Node):
	_ui.add_child(scene)

func get_camera_ref() -> Node:
	return _camera

func exit_dialog():
	use_item_timer.start(0.25)
	in_dialog = false
	control_frozen = false
	dialog_panning = false

func get_money():
	return money

func get_banked_money():
	return banked_money

func set_banked_money(num : int):
	banked_money = num

func anchor(anchor : Node):
	_collision.disabled = true
	control_frozen = true
	is_dashing = false
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
		handle_use_item()
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
			if(dev_zoom_level == 0):
				_camera.zoom_to(0.2)
				dev_zoom_level = 1
			elif(dev_zoom_level == 1):
				_camera.zoom_to(0.05)
				dev_zoom_level = 2
			else:
				dev_zoom_level = 0
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
	if Input.is_action_just_pressed("dev_toggle_fps"):
		_ui.toggle_fps_counter()
	if Input.is_action_just_pressed("dev_advance_time"):
		var time_keeper = get_tree().get_first_node_in_group("time_keeper")
		time_keeper.advance_clock()
		time_keeper.refresh_npc_locations()

func get_current_hp():
	return current_hp

func get_current_v() -> Vector2:
	return current_v

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
		is_dashing = false
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

func disable_collision():
	_collision.disabled = true
	
func enable_collision():
	_collision.disabled = false

func handle_interact():
	if use_item_timer.is_stopped() && Input.is_action_just_pressed("interact"):
		use_item_timer.start(0.25)
		var index = 0
		var grabObj = _grabber.get_collider(0)
		while(index < _grabber.get_collision_count()):
			if(_grabber.get_collider(index).is_in_group("interactable") || 
			_grabber.get_collider(index).is_in_group("pickupable")):
				grabObj = _grabber.get_collider(index)
				break
			index = index + 1
		if(_grabber.is_colliding() && grabObj.is_in_group("interactable")):
			grabObj.interact()
		else:
			handle_pick_up()

func handle_dash():
	if Input.is_action_just_pressed("dash"):
		dash()
	elif Input.is_action_just_released("dash"):
		stop_dash()

func regen_dash_secs(seconds):
	dash_regen_secs = seconds

func get_max_dash_secs():
	return max_dash_secs

func give_dash_seconds(seconds):
	if(current_dash_secs < max_dash_secs):
		if(current_dash_secs + seconds >= max_dash_secs):
			current_dash_secs = max_dash_secs
		else:
			current_dash_secs = current_dash_secs + seconds

func give_dash_fraction(fraction: float):
	give_dash_seconds(max_dash_secs * fraction)

func handle_use_item():
	if(use_item_timer.is_stopped() && Input.is_action_just_pressed("use_item")):
		use_item()
		use_item_timer.start(0.25)
	if(Input.is_action_just_pressed(("switch_item"))):
		if(items.size() > 1):
			if(item_index + 1 == items.size()):
				item_index = 0
			else:
				item_index = item_index + 1

func handle_throw():
	if Input.is_action_just_pressed("throw"):
		throw()

func append_to_items(item : String):
	if(items.find(item) < 0):
		items.append(item)
		item_index = items.find(item)

func use_item():
	if(items.size() > 0 ):
		match items[item_index]:
			pizza:
				stop_dash()
				grabbed_object.use_item()
			flashlight:
				if(camera_connected):
					_camera.toggle_flashlight()
			cardbinder:
				stop_dash()
				var binder = card_binder.instantiate()
				get_parent().add_child(binder)
				main_ui_invisible()
				set_control_frozen(true)

func remove_from_items(item : String):
	items.erase(item)
	item_index = 0

func set_use_item_timer(num : float):
	use_item_timer.start(num)

func set_control_frozen(value):
	control_frozen = value
	if(value):
		is_dashing = false

func set_current_v(vect : Vector2):
	current_v = vect

func stop():
	current_v = Vector2(0,0)

func set_holding_object(is_holding):
	holding_object = is_holding
	_character_base.set_arms_raised(is_holding)

func throw():
	if(holding_object && !_grabber.is_colliding() ):
		sound_player.stream = woosh_sound
		sound_player.play()
		
		if(grabbed_object.is_in_group("pizza")):
			self.remove_from_group("courier")
			remove_from_items("pizza")
			grabbed_object.throw(_character_base.get_facing_dir(),Vector2(0,-16))
		else:
			grabbed_object.throw(_character_base.get_facing_dir())
		grabbed_object = null
		set_holding_object(false)

func put_down():
	sound_player.stream = putdown_sound
	sound_player.play()
	if(grabbed_object.is_in_group("pizza")):
		grabbed_object.put_down(_character_base.get_facing_dir(),Vector2(0,-16))
		self.remove_from_group("courier")
		remove_from_items("pizza")
	else:
		grabbed_object.put_down(_character_base.get_facing_dir())
	grabbed_object = null
	set_holding_object(false)
	
func handle_pick_up():
	if(will_grab_object != null && !holding_object):
		sound_player.stream = pickup_sound
		sound_player.play()
		will_grab_object.pick_up(self)
		grabbed_object = will_grab_object
		if(will_grab_object.is_in_group("pizza")):
			self.add_to_group("courier")
			append_to_items("pizza")
		set_holding_object(true)
	else: if(holding_object):
		if(_grabber.is_colliding()):
			if(grabbed_object.is_in_group("pizza")):
				var delivery_doors = get_tree().get_nodes_in_group("delivery_door")
				#exception for delivery doors
				for door in delivery_doors:
					if(global_position.distance_to(door.global_position) < 32):
						put_down()
				if(holding_object): #if we didn't find a delivery door
					sound_player.stream = bump_sound
					sound_player.play()
			else:
				sound_player.stream = bump_sound
				sound_player.play()
		else:
			put_down()

func return_pizza():
	sound_player.stream = pickup_sound
	sound_player.play()
	var pizza = get_tree().get_first_node_in_group("pizza")
	self.add_to_group("courier")
	append_to_items("pizza")
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
			sound_player.stream = dash_sound
			sound_player.play()
			is_dashing = true
			current_dash_secs = current_dash_secs - 1
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

func finish_load_in():
	loading_in = false
	control_frozen = false
	set_ui_visible()
	show_hearts()
	show_money()
	show_dash()
	#ui noises start off so that we don't hear the money meter ratcheting up
	#as the player loads in
	_ui.turn_on_ui_noises()
	_camera.fade_in()

func update_item_square():
	if(items.size() > 0 && item_index < items.size() && !main_ui_hidden):
		_ui.show_item_square()
		_ui.set_item_square(items[item_index])
	else:
		_ui.hide_item_square()

func _physics_process(delta):
	if(!Engine.is_editor_hint()):
		if(timer_load_in.is_stopped() && loading_in):
			finish_load_in()
			
		if(camera_connected):
			_camera.handle_camera_pan()
		if(!dead):
			get_input()
			if(in_dialog):
				current_v = Vector2(0,0)
			if(push_timer.is_stopped()):
				apply_force(current_v)
			else:
				apply_force(push_vector)
			if(invincibility_timer.is_stopped() &&
			is_invincible == true):
				go_vincible()
			_ui.update_hearts(current_hp)
			_ui.set_money(money)
			if(anchored && active_anchor != null):
				global_position = active_anchor.global_position
			
			update_item_square()
			
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
			if(timer_dash_regen.is_stopped() && dash_regen_secs > 0):
				if(current_dash_secs < max_dash_secs):
					dash_regen_secs = dash_regen_secs - 1
					current_dash_secs = current_dash_secs + 1
					timer_dash_regen.start(0.25)
				else:
					current_dash_secs = max_dash_secs
					dash_regen_secs = 0
			if(speech_instance != null &&
			speech_instance.full_text_displayed):
				if(!comment_waiting):
					comment_timer.start(comment_timer_wait_secs)
					comment_waiting = true
				else:
					if(comment_timer.is_stopped()):
						speech_instance.queue_free()
		
