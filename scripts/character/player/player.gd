@tool
extends RigidBody2D

@onready var _character_base = $character_base
@onready var _grabber = $grabber
@onready var _tough_luck = $tough_luck
@onready var _collision = $CollisionShape2D
@onready var _ui_canvas = $ui_canvas
@onready var _ui = $ui_canvas/player_ui
@onready var _light = $player_light
@onready var _skateboard = $skateboard
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

var base_temp_storage : SpriteFrames = null
@onready var dreamer_spriteframes : SpriteFrames = preload("res://sprites/spritesheets/spriteframes/characters/base/raccoon_base.tres")
var dreaming = false
#var sleep_start_time = 18
#var sleep_end_time = 9

var no_clip = false
var dev_zoom_level = 0
const no_clip_speed = 3200000

var get_cd_interface = preload("res://interface/get_cd_interface.tscn")

var journal = preload("res://interface/journal_interface.tscn")
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
var footfall_sound = preload("res://audio/soundFX/footfall_1.wav")
var flashlight_sound = preload("res://audio/soundFX/click.ogg")
var damage_sound = preload("res://audio/soundFX/damage.ogg")
var maracca_sound = preload("res://audio/soundFX/maracca.ogg")
var skateboard_sound = preload("res://audio/soundFX/skateboard.ogg")

var sound_player := AudioStreamPlayer.new()
var sound_player2 := AudioStreamPlayer.new()
var sound_player3 := AudioStreamPlayer.new()
var sound_player4 := AudioStreamPlayer.new()
var sound_player5 := AudioStreamPlayer.new()
var sound_players : Array[AudioStreamPlayer] = [sound_player,sound_player2,sound_player3,sound_player4,sound_player5]

var can_play_footfall = false
var footfall_player := AudioStreamPlayer.new()

var skateboard_player := AudioStreamPlayer.new()

var timer_load_in : Timer = Timer.new()
var loading_in : bool = false

const normal_speed = 50000
const dash_speed = 100000
var acceleration_quotient = normal_speed
const top_speed = 180

var start_max_dash_secs : float = 20.0
var current_dash_secs : float = 0.0
var max_dash_secs : float = start_max_dash_secs
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

var days_since_rent_paid = 0

var holding_object = false
var will_grab_object = null
var grabbed_object = null
var control_frozen = false
var movement_frozen = false
var items_frozen = false
var current_v = Vector2(0,0)

const full_max_hp = 6
var max_hp = 3
var current_hp = 3
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

var dev_occlusion_level = 0

var item_text_timer : Timer = Timer.new()
var use_item_timer : Timer = Timer.new()

#for tracking tutorial tips
var first_used_dash : bool = false
var first_used_item : bool = false
var first_switched_item : bool = false
var first_used_journal : bool = false

func has_first_used_dash() -> bool: return first_used_dash
func has_first_used_item() -> bool: return first_used_item
func has_first_switched_item() -> bool: return first_switched_item
func has_first_used_journal() -> bool: return first_used_journal

#TODO: character gen when the game starts to randomly choose some defaults? Let the player choose defaults?
#empty string "" -> default, empty slot. Note bottoms default is pants_0
var hats_index = 0
var tops_index = 0
var bottoms_index = 0
var owned_hats : Array[String] = ["", "res://sprites/spritesheets/spriteframes/characters/hat/full_sheet/cap_0.tres"]
var owned_tops : Array[String] = ["", "res://sprites/spritesheets/spriteframes/characters/top/full_sheet/shirt_0.tres"]
var owned_bottoms : Array[String] = ["", "res://sprites/spritesheets/spriteframes/characters/bottom/full_sheet/pants_0.tres"]

var items : Array[String] = []
var item_index : int = 0
var shown_items_tip : bool = false

var owned_music : Array[String] = []

var owned_maps : Array[String] = ["West Side", "Central Stonesthrow"]

var default_linear_damp : float = 6.0
var skating_linear_damp : float = 0.1
var skating : bool = false
var skating_top_speed : float = -1.0

var main_ui_hidden = false

var ui_scene_ref = null

#item cosnt
const flashlight : String = "flashlight"
const pizza : String = "pizza"
const cardbinder : String = "card_binder"
const citymap : String = "city_map"
const firecracker: String = "fire_cracker"
const skateboard : String = "skateboard"

var num_fire_crackers : int = 0
var max_fire_crackers : int = 9

var waking = false
var waking_control_back = false

var checking_light_distance : bool = false
var light_distance_check_timer := Timer.new()
var should_wake_up = false

var quest_state_keys : Array[String] = []
var quest_state_values : Array[String] = []

var quest_log_keys : Array[String] = ["start", "start_door"]
var quest_log_values : Array[int] = [0,1]

var journal_tabs : Array[String] = ["quest_journal"]

func _ready():
	_collision.disabled = no_clip
	timer_dash.one_shot = true
	timer_dash_regen.one_shot = true
	invincibility_timer.one_shot = true
	use_item_timer.one_shot = true
	timer_load_in.one_shot = true
	push_timer.one_shot = true
	item_text_timer.one_shot = true
	light_distance_check_timer.one_shot = true
	
	comment_timer.one_shot = true
	set_up_sound_players()
	footfall_player.bus = "Effects"
	footfall_player.volume_db = -26
	footfall_player.stream = footfall_sound
	skateboard_player.bus = "Effects"
	skateboard_player.stream = skateboard_sound
	add_child(skateboard_player)
	add_child(footfall_player)
	add_child(timer_dash)
	add_child(timer_dash_regen)
	add_child(invincibility_timer)
	add_child(comment_timer)
	add_child(use_item_timer)
	add_child(timer_load_in)
	add_child(push_timer)
	add_child(item_text_timer)
	add_child(light_distance_check_timer)
	
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

func get_quest_log_keys() -> Array[String]:
	return quest_log_keys

func get_quest_log_values()-> Array[int]:
	return quest_log_values

func get_days_since_paid_rent():
	return days_since_rent_paid

func set_days_since_paid_rent(num : int):
	days_since_rent_paid = num

func set_checking_light_distance(value : bool):
	checking_light_distance = value

func set_up_sound_players():
	for player in sound_players:
		player.bus = "Effects"
		add_child(player)

func play_sound(stream : AudioStream):
	for player in sound_players:
		if(!player.playing):
			player.stream = stream
			player.play()
			return

func set_quest_state(key : String, value : String):
	var key_index : int = quest_state_keys.find(key)
	if(key_index >= 0):
		quest_state_values[key_index] = value
	else:
		quest_state_keys.append(key)
		quest_state_values.append(value)

func get_quest_state(key : String) -> String:
	var ret_state = ""
	var key_index : int = quest_state_keys.find(key)
	if(key_index >= 0):
		ret_state = quest_state_values[key_index]
	return ret_state

func begin_dreaming():
	if(holding_object):
		put_down()
	dreaming = true
	base_temp_storage = _character_base.get_base_spriteframes()
	_character_base.set_base_spriteframes(dreamer_spriteframes)
	_character_base.reduce_to_base()
	set_ui_invisible()
	var dark_ysort = get_tree().get_first_node_in_group("dark_indoor_ysort")
	var flat_light_layer = get_tree().get_first_node_in_group("flat_light_layer")
	var day_light_layer = get_tree().get_first_node_in_group("daylight_layer")
	var dark_layer = get_tree().get_first_node_in_group("dark_layer")
	reparent(dark_ysort)
	day_light_layer.visible = false
	flat_light_layer.visible = false
	dark_layer.visible = true
	var dream_spawn = get_tree().get_first_node_in_group("player_spawn_dream")
	global_position = dream_spawn.global_position

func stop_dreaming():
	dreaming = false
	if(holding_object):
		put_down(false)
	_character_base.set_base_spriteframes(base_temp_storage)
	_character_base.restore_non_base_sprites()
	var day_light_ysort = get_tree().get_first_node_in_group("daylight_affected_ysort")
	reparent(day_light_ysort)
	var day_light_layer = get_tree().get_first_node_in_group("daylight_layer")
	var dark_layer = get_tree().get_first_node_in_group("dark_layer")
	var flat_light_layer = get_tree().get_first_node_in_group("flat_light_layer")
	day_light_layer.visible = false
	dark_layer.visible = false
	flat_light_layer.visible = false
	var bedroom_spawn = get_tree().get_first_node_in_group("player_spawn_bedroom")
	global_position = bedroom_spawn.global_position
	#we have to go and execute all the triggered pruners since the
	#player may exit the dream from anywhere
	var dream_pruners = get_tree().get_nodes_in_group("dream_pruners")
	for pruner in dream_pruners:
		pruner.run_script()
	

func wake_up():
	if(!waking):
		stop()
		linear_velocity = Vector2(0,0)
		set_control_frozen(true)
		get_camera_ref().fade_out()
		timer_load_in.start(1)
		waking = true

func add_owned_cd(key : String):
	var get_cd = get_cd_interface.instantiate()
	get_cd.global_position = get_camera_ref().get_screen_center_position()
	get_parent().add_child(get_cd)
	get_cd.play(key)
	if(!owned_music.has(key)):
		owned_music.append(key)

func remove_owned_cd(key : String):
	if(owned_music.has(key)):
		owned_music.erase(key)

func has_owned_cd(key : String) -> bool:
	var has_key : bool = owned_music.has(key)
	return has_key

#check_light
func light_is_on_screen():
	if(no_clip):
		return true
	var lights = get_tree().get_nodes_in_group("dream_light_source")
	var check_distance = 100
	var light_on_screen = false
	for light in lights:
		var test : Vector2 = self.global_position
		var test2: Vector2 = light.global_position
		if(self.global_position.distance_to(light.global_position) < check_distance):
			light_on_screen = true
			break
	return light_on_screen

func handle_waking():
	if(checking_light_distance):
		if(!should_wake_up && !light_is_on_screen()):
			should_wake_up = true
			light_distance_check_timer.start(0.5)
		elif(should_wake_up && light_is_on_screen()):
			should_wake_up = false
		elif(light_distance_check_timer.is_stopped() && should_wake_up):
			wake_up()
			should_wake_up = false
			checking_light_distance = false
	#if(!waking || waking_control_back):
		#var time_keeper = get_tree().get_first_node_in_group("time_keeper")
		#if(time_keeper != null):
			#if(time_keeper.clock > sleep_end_time &&
			#time_keeper.clock < sleep_start_time &&
			#(!waking || waking_control_back) &&
			#dreaming):
				#wake_up()

	if(timer_load_in.is_stopped()):
		if(waking):
			stop_dreaming()
			timer_load_in.start(4)
			waking = false
			waking_control_back = true
		elif(waking_control_back):
			var day_light_layer = get_tree().get_first_node_in_group("daylight_layer")
			day_light_layer.visible = true
			get_camera_ref().fade_in()
			waking_control_back = false
			set_ui_visible()
			set_control_frozen(false)
			#var baby_spawner = get_tree().get_first_node_in_group("dream_baby_spawn")
			#baby_spawner.reset_has_played()

#called when the player loads in from a save
func load_in():
	if(!loading_in):
		loading_in = true
		set_ui_invisible()
		control_frozen = true
		timer_load_in.start(6)
		var time_keeper = get_tree().get_first_node_in_group("time_keeper")
		#time_keeper.set_clock(9)
		time_keeper.unlock_time()
		var secondary_music_player = get_tree().get_first_node_in_group("secondary_music_player")
		secondary_music_player.stream = load("res://audio/music/sleep theme.wav")
		secondary_music_player.play()
		#var stream = load("res://audio/music/sleep theme.wav")
		#play_sound(stream)

func set_and_update_cloths(hat : int, top : int, bottom : int):
	hats_index = hat
	tops_index = top
	bottoms_index = bottom
	var hat_str : String = owned_hats[hats_index]
	var top_str : String = owned_tops[tops_index]
	var bottom_str : String = owned_bottoms[bottoms_index]
	if(hat_str != ""):
		hat_spriteframes = load(hat_str)
	else:
		hat_spriteframes = null
	if(top_str != ""):
		top_spriteframes = load(top_str)
	else:
		top_spriteframes = null
	if(bottom_str != ""):
		bottom_spriteframes = load(bottom_str)
	else:
		bottom_spriteframes = null
	_character_base.set_spriteframes_include_null(base_spriteframes,
	hat_spriteframes,
	top_spriteframes,
	bottom_spriteframes)
	_character_base.stand_dir(facing_dir)

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

func append_owned_hat(resource_path : String):
	if(!owned_hats.has(resource_path)):
		owned_hats.append(resource_path)

func append_owned_top(resource_path : String):
	if(!owned_tops.has(resource_path)):
		owned_tops.append(resource_path)

func append_owned_bottom(resource_path : String):
	if(!owned_bottoms.has(resource_path)):
		owned_bottoms.append(resource_path)

func get_owned_hats() -> Array[String]:
	return owned_hats

func get_owned_tops() -> Array[String]:
	return owned_tops

func get_owned_bottoms() -> Array[String]:
	return owned_bottoms

func get_owned_music() -> Array[String]:
	return owned_music

func get_owned_maps() -> Array[String]:
	return owned_maps

#called when the player starts a new game
func new_game():
	var time_keeper = get_tree().get_first_node_in_group("time_keeper")
	time_keeper.set_clock(17)

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
		"current_hp" : current_hp,
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
		"items" : items,
		"owned_hats" : owned_hats,
		"owned_tops" : owned_tops,
		"owned_bottoms" : owned_bottoms,
		"owned_music" : owned_music,
		"hats_index" : hats_index,
		"tops_index" : tops_index,
		"bottoms_index" : bottoms_index,
		"num_fire_crackers" : num_fire_crackers,
		"days_since_rent_paid" : days_since_rent_paid,
		"quest_state_keys" : quest_state_keys,
		"quest_state_values" : quest_state_values,
		"shown_items_tip" : shown_items_tip,
		"journal_tabs" : journal_tabs,
		"owned_maps" : owned_maps
	}
	return save_dictionary

func get_base() -> String:
	return base_spriteframes.resource_path

func push(push_vect : Vector2, time_secs : float):
	push_timer.start(time_secs)
	stop()
	push_vector = push_vect
	stop_skateboarding()

func load_from_dictionary(load_dictionary : Dictionary):
	var parent_group = String(load_dictionary.get("parent_group"))
	var parent = get_tree().get_first_node_in_group(parent_group)
	reparent(parent)
	global_position = Vector2(load_dictionary.get("pos_x"), load_dictionary.get("pos_y"))
	max_hp = int(load_dictionary.get("max_hp"))
	_ui.set_max_hearts(max_hp)
	current_hp = int(load_dictionary.get("current_hp"))
	_ui.update_hearts(current_hp)
	max_dash_secs = load_dictionary.get("max_dash_secs")
	update_max_dash_meter()
	current_dash_secs = load_dictionary.get("current_dash_secs")
	money = int(load_dictionary.get("money"))
	_ui.set_money(money,true)
	banked_money = load_dictionary.get("banked_money")
	shown_items_tip = bool(load_dictionary.get("shown_items_tip"))
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
	
	var load_num_fire_crackers = int(load_dictionary.get("num_fire_crackers"))
	num_fire_crackers = load_num_fire_crackers
	
	var load_days_since_rent_paid = int(load_dictionary.get("days_since_rent_paid"))
	days_since_rent_paid = load_days_since_rent_paid
	
	var hats_index = load_dictionary.get("hats_index")
	var tops_index = load_dictionary.get("tops_index")
	var bottoms_index = load_dictionary.get("bottoms_index")
	while(index < load_items.size()):
		items.append(String(load_items[index]))
		index = index + 1
	var load_hats = load_dictionary.get("owned_hats")
	index = 0
	while(index < load_hats.size()):
		append_owned_hat(String(load_hats[index]))
		index = index + 1
	var load_tops = load_dictionary.get("owned_tops")
	index = 0
	while(index < load_tops.size()):
		append_owned_top(String(load_tops[index]))
		index = index + 1
	var load_bottoms = load_dictionary.get("owned_bottoms")
	index = 0
	while(index < load_bottoms.size()):
		append_owned_bottom(String(load_bottoms[index]))
		index = index + 1
		
	var load_music = load_dictionary.get("owned_music")
	index = 0
	while(index < load_music.size()):
		var loaded_key_str = String(load_music[index])
		if(!owned_music.has(loaded_key_str)):
			owned_music.append(loaded_key_str)
		index = index + 1
	
	var load_maps = load_dictionary.get("owned_maps")
	index = 0
	while(index < load_maps.size()):
		var loaded_map_str = String(load_maps[index])
		if(!owned_maps.has(loaded_map_str)):
			owned_maps.append(loaded_map_str)
		index = index + 1
	
	var load_journal = load_dictionary.get("journal_tabs")
	index = 0
	while(index < load_journal.size()):
		var loaded_journal_str = String(load_journal[index])
		if(!journal_tabs.has(loaded_journal_str)):
			journal_tabs.append(loaded_journal_str)
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
	
	var load_quest_keys = load_dictionary.get("quest_state_keys")
	var load_quest_values = load_dictionary.get("quest_state_values")
	index = 0
	while(index < load_quest_keys.size()):
		var key = String(load_quest_keys[index])
		var value = String(load_quest_values[index])
		set_quest_state(key,value)
		index = index + 1

func set_deck(deck : Array[int]):
	card_deck = deck

func get_deck() -> Array[int]:
	return card_deck

func add_owned_card(card : int):
	if(!journal_tabs.has(cardbinder)):
		journal_tabs.append(cardbinder)
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

func add_fire_crackers(num : int):
	if(num_fire_crackers == 0):
		append_to_items(firecracker)
	if(num_fire_crackers + num > max_fire_crackers):
		num_fire_crackers = max_fire_crackers
	else:
		num_fire_crackers = num_fire_crackers + num
	_ui.update_quantity_label_text(str(num_fire_crackers))

func enter_dialog():
	stop()
	control_frozen = true
	is_dashing = false
	dialog_panning = true
	in_dialog = true
	if(camera_connected):
		_camera.turn_off_flashlight()

func set_dialog_panning(input: bool):
	dialog_panning = input

func update_max_dash_meter():
	_ui.set_max_dash_fraction(max_dash_secs / full_dash_secs)

func update_dash_meter():
	update_max_dash_meter()
	if(current_dash_secs < 1.0):
		_ui.set_dash_fraction(0.0)
	else:
		_ui.set_dash_fraction(current_dash_secs / max_dash_secs)

func add_to_max_dash_secs(num : int):
	if(max_dash_secs == start_max_dash_secs):
		show_tip("[color=cyan]Crystals[/color] expand the [color=cyan]energy meter.[/color]",true,false,[],[],[],6.0)
	var new_max_dash_secs = max_dash_secs + num
	if new_max_dash_secs < full_dash_secs:
		max_dash_secs = new_max_dash_secs
	update_dash_meter()
	play_sound(crystal_sound)
	
	

func hide_tip():
	_ui.hide_tip()

func show_tip(text : String, 
arrow_left : bool = false, 
arrow_right : bool = false,
glyph_acts_1 : Array[String] = [],
glyph_acts_2 : Array[String] = [],
glyph_acts_3 : Array[String] = [],
dismiss_timer : float = 0.0):
	_ui.show_tip(text,arrow_left,arrow_right,glyph_acts_1,glyph_acts_2,glyph_acts_3,dismiss_timer)

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

func opening_ui_invisible():
	_ui.hide_interact_text()
	_ui.hide_tip()

func opening_ui_visible():
	_ui.show_interact_text()

func main_ui_invisible():
	hide_hearts()
	hide_money()
	hide_dash()
	_ui.hide_interact_text()
	_ui.hide_item_square()
	main_ui_hidden = true
	_ui.hide_tip()
	

func main_ui_visible():
	show_hearts()
	show_money()
	show_dash()
	_ui.show_interact_text()
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

func exit_dialog(set_control_frozen : bool = false):
	use_item_timer.start(0.25)
	in_dialog = false
	control_frozen = set_control_frozen
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
		if(!skating):
			if Input.is_action_pressed(direction.right):
				_character_base.face_right()
			else: if Input.is_action_pressed(direction.left):
				_character_base.face_left()
			else: if Input.is_action_pressed(direction.up):
				_character_base.face_up()
			else: if Input.is_action_pressed(direction.down):
				_character_base.face_down()
		else:
			_skateboard.play(_character_base.facing_dir)
			_skateboard.speed_scale = speed()/top_speed
			_character_base.skate_pose_sprite_by_vector(linear_velocity)
		handle_interact()
		handle_throw()
		handle_dash()
		handle_use_item()
		handle_journal()
		handle_dev()
		move()

func handle_journal():
	if(Input.is_action_just_pressed("journal")):
		var journal_ref = journal.instantiate()
		journal_ref.global_position = get_camera_ref().get_screen_center_position()
		get_parent().add_child(journal_ref)
		journal_ref.open(journal_tabs)
		var time_keeper = get_tree().get_first_node_in_group("time_keeper")
		var music_continues = true
		main_ui_invisible()
		set_control_frozen(true)
		time_keeper.pause_parent_tree(music_continues)

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
				_camera.zoom_to(0.06)
				dev_zoom_level = 2
			else:
				dev_zoom_level = 0
				_camera.zoom_to(1.0)
	if Input.is_action_just_pressed("dev_toggle_occluders"):
		var prune_manager = get_tree().get_first_node_in_group("tree_prune_manager")
		dev_occlusion_level = dev_occlusion_level + 1
		if(dev_occlusion_level == 1):
			prune_manager.toggle_bypass(true)
		if(dev_occlusion_level == 2):
			visible = false
			var npcs = get_tree().get_nodes_in_group("npc")
			for npc in npcs:
				npc.visible = false
			var mobs = get_tree().get_nodes_in_group("mobster")
			for mob in mobs:
				mob.visible = false
		if(dev_occlusion_level == 3):
			dev_occlusion_level = 0
			var npcs = get_tree().get_nodes_in_group("npc")
			visible = true
			for npc in npcs:
				npc.visible = true
			var mobs = get_tree().get_nodes_in_group("mobster")
			for mob in mobs:
				mob.visible = true
			prune_manager.toggle_bypass(false)
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

func shake_camera(magnitude : int):
	_camera.shake(magnitude)

func reduce_hp(amount : int = 1, nonlethal : bool = false):
	stop_skateboarding()
	current_hp = current_hp - amount
	if(nonlethal && current_hp == 0):
		current_hp = 1
	_ui.update_hearts(current_hp)
	play_sound(damage_sound)
	_camera.shake(8 + (max_hp - current_hp)*2)
	if(current_hp == 0):
		_character_base.stop_flashing()
		die()
	else:
		go_invincible()

func increment_max_hp():
	if(max_hp < full_max_hp):
		max_hp = max_hp + 1
		_ui.set_max_hearts(max_hp)
		current_hp = max_hp
		_ui.update_hearts(current_hp)

func _on_body_entered(body:Node):
	if(body.is_in_group("bullet")):
		if(body.is_in_group("nonlethal")):
			reduce_hp(0)
		else:
			reduce_hp()

func _on_make_comment(text : String):
	if(!dreaming && !in_dialog):
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

func handle_interact_text():
	if(item_text_timer.is_stopped()):
		if(_grabber.get_collision_count() > 0):
			var grabObj = _grabber.get_collider(0)
			var index = 0
			while(index < _grabber.get_collision_count()):
				if(_grabber.get_collider(index) != null):
					if(_grabber.get_collider(index).is_in_group("interactable") || 
					_grabber.get_collider(index).is_in_group("pickupable")):
						grabObj = _grabber.get_collider(index)
						break
					index = index + 1
			if(_grabber.get_collider(index) != null):
				if(_grabber.get_collider(index).is_in_group("pizza")):
					_ui.set_interact_text("pick up")
				elif(_grabber.get_collider(index).is_in_group("talkable")):
					_ui.set_interact_text("talk")
				elif(_grabber.get_collider(index).is_in_group("lookable")):
					_ui.set_interact_text("look")
				elif(_grabber.get_collider(index).is_in_group("interactable") &&
				!_grabber.get_collider(index).is_in_group("npc") &&
				!_grabber.get_collider(index).is_in_group("reads_pickupable")):
					_ui.set_interact_text("use")
				elif(!holding_object && 
				(_grabber.get_collider(index).is_in_group("pickupable") ||
				_grabber.get_collider(index).is_in_group("reads_pickupable"))):
					_ui.set_interact_text("pick up")
				else:
					if(!holding_object):
						_ui.deactivate_interact()
		else:
			if(holding_object):
				_ui.set_interact_text("drop")
			else:
				_ui.deactivate_interact()
		item_text_timer.start(0.25)

func handle_interact():
	handle_interact_text()
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
	if(!dreaming):
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
	if(!dreaming):
		if(items.size() > 0):
			if(use_item_timer.is_stopped() && Input.is_action_just_pressed("use_item")):
				use_item()
				use_item_timer.start(0.25)
			if(items.size() > 1):
				if(Input.is_action_just_pressed(("switch_item_right")) && !items_frozen):
					play_sound(pickup_sound)
					if(items.size() > 1):
						if(item_index + 1 == items.size()):
							item_index = 0
						else:
							item_index = item_index + 1
				elif(Input.is_action_just_pressed(("switch_item_left")) && !items_frozen):
					play_sound(pickup_sound)
					if(items.size() > 1):
						if(item_index - 1 < 0):
							item_index = items.size() - 1
						else:
							item_index = item_index - 1

func handle_throw():
	if Input.is_action_just_pressed("throw"):
		throw()

func append_to_items(item : String):
	if(items.find(item) < 0):
		items.append(item)
		item_index = items.find(item)
	if(items.size() > 1 && !shown_items_tip):
		show_tip("[action_1] and [action_2] to switch items. \n [action_3] to use item.",
		false,true,
		["switch_item_left"],
		["switch_item_right"],
		["use_item"], 
		6.0)
		shown_items_tip = true

func use_item():
	if(items.size() > 0 ):
		match items[item_index]:
			pizza:
				stop_dash()
				grabbed_object.use_item()
			flashlight:
				if(camera_connected):
					play_sound(flashlight_sound)
					_camera.toggle_flashlight()
			cardbinder:
				stop_dash()
				var binder = card_binder.instantiate()
				get_parent().add_child(binder)
				main_ui_invisible()
				set_control_frozen(true)
			citymap:
				if(ui_scene_ref == null):
					stop()
					set_movement_frozen(true)
					set_items_frozen(true)
					play_sound(maracca_sound)
					var map = load("res://interface/city_map.tscn")
					ui_scene_ref = map.instantiate()
					add_scene_to_ui_tree(ui_scene_ref)
				else:
					play_sound(maracca_sound)
					set_movement_frozen(false)
					set_items_frozen(false)
					ui_scene_ref.queue_free()
			firecracker:
				if(num_fire_crackers > 0):
					var scene_fire_cracker = load("res://entities/props/dynamic props/fire_cracker.tscn")
					var fire_cracker = scene_fire_cracker.instantiate()
					fire_cracker.global_position = global_position
					add_child(fire_cracker)
					fire_cracker.throw_bypass_pickup(_character_base.get_facing_dir(), self)
					num_fire_crackers = num_fire_crackers - 1
					_ui.update_quantity_label_text(str(num_fire_crackers))
				if(num_fire_crackers <= 0):
					num_fire_crackers = 0
					remove_from_items(firecracker)
			skateboard:
				if(!skating):
					start_skateboarding()
				else:
					stop_skateboarding()

func start_skateboarding():
	skating = true
	play_sound(maracca_sound)
	skateboard_player.play()
	_skateboard.visible = true
	if(is_dashing):
		linear_velocity = linear_velocity * 1.35
	physics_material_override.bounce = 1.0
	linear_damp = skating_linear_damp
	skating_top_speed = speed()

func stop_skateboarding():
	skateboard_player.stop()
	_skateboard.visible = false
	play_sound(maracca_sound)
	skating = false
	linear_damp = default_linear_damp
	physics_material_override.bounce = 0.0
	skating_top_speed = 0.0

func set_movement_frozen(input: bool):
	movement_frozen = input

func remove_from_items(item : String):
	items.erase(item)
	item_index = 0

func set_use_item_timer(num : float):
	use_item_timer.start(num)

func control_is_frozen():
	return control_frozen

func set_control_frozen(value):
	control_frozen = value
	if(value):
		is_dashing = false

func set_items_frozen(value: bool):
	items_frozen = value

func set_current_v(vect : Vector2):
	current_v = vect

func stop():
	current_v = Vector2(0,0)
	stop_dash()

func complete_stop():
	current_v = Vector2(0,0)
	linear_velocity = Vector2(0,0)
	stop_dash()

func set_holding_object(is_holding):
	holding_object = is_holding
	_character_base.set_arms_raised(is_holding)

func throw():
	if(holding_object && !_grabber.is_colliding() ):
		play_sound(woosh_sound)
		if(grabbed_object != null):
			if(grabbed_object.is_in_group("pizza")):
				self.remove_from_group("courier")
				remove_from_items("pizza")
				grabbed_object.throw(_character_base.get_facing_dir(),Vector2(0,-16))
			else:
				grabbed_object.throw(_character_base.get_facing_dir())
		grabbed_object = null
		set_holding_object(false)
		_ui.deactivate_interact()
		item_text_timer.start(0.25)

func put_down(play_sound = true):
	if(play_sound):
		play_sound(putdown_sound)
	if(grabbed_object != null):
		if(grabbed_object.is_in_group("pizza")):
			grabbed_object.put_down(_character_base.get_facing_dir(),Vector2(0,-16))
			self.remove_from_group("courier")
			remove_from_items("pizza")
		else:
			grabbed_object.put_down(_character_base.get_facing_dir())
	grabbed_object = null
	set_holding_object(false)
	_ui.deactivate_interact()

func put_down_and_return():
	if(grabbed_object != null):
		var temp = grabbed_object
		put_down(false)
		temp.return_to_home()

func handle_pick_up():
	if(will_grab_object != null && !holding_object):
		play_sound(pickup_sound)
		will_grab_object.pick_up(self)
		grabbed_object = will_grab_object
		if(will_grab_object.is_in_group("pizza")):
			self.add_to_group("courier")
			var pizza_parent = get_tree().get_first_node_in_group("pizza_parent")
			if(!pizza_parent.get_is_tutorial()):
				append_to_items("pizza")
		set_holding_object(true)
		_ui.set_interact_text("drop")
	else: if(holding_object):
		if(_grabber.is_colliding()):
			if(grabbed_object.is_in_group("pizza")):
				var delivery_doors = get_tree().get_nodes_in_group("delivery_door")
				#exception for delivery doors
				for door in delivery_doors:
					if(global_position.distance_to(door.global_position) < 32):
						put_down()
				if(holding_object): #if we didn't find a delivery door
					play_sound(bump_sound)
			else:
				play_sound(bump_sound)
		else:
			put_down()

func return_pizza():
	play_sound(pickup_sound)
	var pizza = get_tree().get_first_node_in_group("pizza")
	var pizza_parent = get_tree().get_first_node_in_group("pizza_parent")
	self.add_to_group("courier")
	if(!pizza_parent.get_is_tutorial()):
		append_to_items("pizza")
	pizza.pick_up(self)
	_ui.set_interact_text("drop")
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
			play_sound(dash_sound)
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

func play_animation(name : String):
	_character_base.play

func move():
	var input_direction = Input.get_vector(direction.left, direction.right, direction.up, direction.down)
	
	if(!movement_frozen):
		#accelerate if we have't hit max
		if(!skating && input_direction.length() != 0 && speed() < top_speed):
			current_v = input_direction * acceleration_quotient
		elif(skating && input_direction.length() != 0 && speed() != 0 && speed() < skating_top_speed):
			current_v = input_direction * normal_speed
		else:
			current_v = input_direction * 0
		
		_character_base.set_animation_scale(0.2, 0.8, speed(), top_speed)
		if(current_v.length() > 0):
			if(_character_base.get_base_current_frame() == 1 || _character_base.get_base_current_frame() == 3):
				if(can_play_footfall):
					footfall_player.play()
					can_play_footfall = false
			else:
				can_play_footfall = true

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
	_ui.update_quantity_label_text(str(num_fire_crackers))
	
	var landlord_manager = get_tree().get_first_node_in_group("landlord_manager")
	landlord_manager.check_if_rent_overdue()

func update_item_square():
	if(items.size() > 0 && item_index < items.size() && !main_ui_hidden):
		_ui.show_item_square()
		_ui.set_item_square(items[item_index])
	else:
		_ui.hide_item_square()

func _physics_process(delta):
	if(!Engine.is_editor_hint()):
		handle_waking()
		
		if(timer_load_in.is_stopped() && loading_in):
			finish_load_in()
			
		if(camera_connected):
			_camera.handle_camera_pan()
		if(!dead):
			get_input()
			
			if(skating):
				skating_top_speed = skating_top_speed - 0.1
				if(speed() < skating_top_speed):
					skating_top_speed = speed()
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
			
			if(!skating):
				_character_base.animate_sprite_by_vector(current_v, (speed() >= top_speed))
			elif(skating):
				_character_base.animate_sprite_by_vector(linear_velocity, (speed() >= top_speed))
				var vol : float = (-80.0 + (50.0 * (speed()/top_speed)))
				if (vol > -20.0): #defending the player's ear drums
					vol = -20.0
				skateboard_player.volume_db = vol
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
		
