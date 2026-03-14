@tool
class_name NPC
extends RigidBody2D

#behavior Directives
const full_passive = "full_passive"
const alert_passive = "alert_passive"

@export var talk_radius = 100
@export var facingPosition = "left"
#@export var ai_directive = full_passive
@export var voice = "none"

@export var base_spriteframes : SpriteFrames
@export var hat_spriteframes : SpriteFrames
@export var top_spriteframes : SpriteFrames
@export var bottom_spriteframes : SpriteFrames
@export var facing_dir = "right"
@export var dialog_offset = Vector2(0,0)
@export var starting_index = 0
@export var no_face_player : bool = false
@export var alt_dlg_bubble_path : String = ""

#assign this with a node that has a script you wanna
#on the event of a collision
@export var body_enter_script_node : Node = null 

#denotes npcs which do not use the typical character_base
#generally for mostly stationary npcs with unique
#shapes and animation patterns. bool=true skips all character_base setup
#and movement code. This assumes that the script is attached to an npc
#where _character_base has a character_base_animatronic script
#and all animation movement will be handled by bespoke scripts
@export var is_animatronic = false

@export var exempt_from_npc_refresh = false

@export var save_tag : String = ""

@export var has_vision : bool = false
@export var has_hearing : bool = false

#array of all schedules this NPC will use
@export var schedule_keys : Array[String] = []
@export var schedules : Array[schedule] = []
var schedules_index

#@export var passive_text = ""

@export var shop : shop_manager = null
@export var branching_dialog : dialog_tree
var dialog = preload("res://dialog/dialog.tscn")
var dialog_manager : Node

@onready var _character_base = $character_base

#data type representing NPC's knowledge of itself and its surroundings
var perceptions: NPCPerceptions = NPCPerceptions.new()

#state machine reference
@onready var _ai_state_machine = $ai_state_machine

@onready var _vision : ShapeCast2D = $vision

var _navigation_agent: NavigationAgent2D = NavigationAgent2D.new()

var exclaim_sound = preload("res://audio/soundFX/voice/sine_voice/1.wav")
var exclaim_bubble = preload("res://entities/characters/NPC/mobsters/communication/exclaim.tscn")

var can_talk_bubble = preload("res://interface/can_talk_bubble.tscn")
var speech_bubble = preload("res://dialog/speech_bubble.tscn")
var talking = false
var has_talked = false
var showing_bubble = false

var ray_collision_mask = 0b00000000_00000000_00000000_00010001

const top_speed = 125000
const nav_target_reached_distance = 8.0 #distance at which nav target is considered reached
const nav_path_resolution = 4

var sound_player := AudioStreamPlayer2D.new()
var footfall_player := AudioStreamPlayer2D.new()
var can_play_footfall = true

var bubble_instance = null
var speech_instance = null

var current_v = Vector2(0,0)
var immobilized = false

var player_ref

var reparent_node = null

# Called when the node enters the scene tree for the first time.
func _ready():
	schedules_index = starting_index
	set_up_character_base()
	set_up_sound_player()
	if(!is_animatronic):
		set_up_nav_agent()
	update_perceptions()
	send_perceptions()
	if(!Engine.is_editor_hint()):
		player_ref = get_tree().get_nodes_in_group("player")[0]
	else:
		queue_redraw()

func set_up_character_base():
	if(!is_animatronic):
		_character_base.set_facing_dir(facing_dir)
		_character_base.set_spriteframes(base_spriteframes,
		hat_spriteframes,
		top_spriteframes,
		bottom_spriteframes)
		_character_base.stand_dir(_character_base.facing_dir)
	else:
		_character_base.set_spriteframes(base_spriteframes)
		_character_base.play_animation("default")

func _on_stand_dir(stand : String):
	if(stand == ""):
		_character_base.stand_dir(perceptions.facing_dir)
		_character_base.set_animation_scale_ratio(1)
	else:
		_character_base.stand_dir(stand)
		_character_base.set_animation_scale_ratio(1)

func get_save_tag() -> String:
	return save_tag

func set_up_nav_agent():
	#nav agent setup stuff
	add_child(_navigation_agent)
	_navigation_agent.path_desired_distance = 4.0
	_navigation_agent.target_desired_distance = 4.0

func set_up_sound_player():
	sound_player.max_distance = 500
	sound_player.attenuation = 2
	sound_player.bus = "Effects"
	add_child(sound_player)
	
	footfall_player.max_distance = 500
	footfall_player.attenuation = 8
	footfall_player.volume_db = -24
	add_child(footfall_player)
	footfall_player.stream = load("res://audio/soundFX/footfall_1.wav")

func play_sound(path : String):
	sound_player.stream = load(path)
	sound_player.play()

func stop_sound():
	sound_player.stop()

func send_perceptions():
	if(_ai_state_machine != null):
		_ai_state_machine.receive_perceptions(perceptions)

func update():
	update_perceptions()

func update_branching_dialog():
	if(schedules.size() > 0):
		if(perceptions.current_stage_mark.get_branching_dialog() != null):
			branching_dialog = perceptions.current_stage_mark.get_branching_dialog()
		else:
			branching_dialog = null

func _on_stop_motion():
	_character_base.set_animation_scale_ratio(1)
	current_v = Vector2(0,0)
	linear_velocity = Vector2(0,0)

func get_is_animatronic():
	return is_animatronic

func interact(stop_bypass : bool = false):
	if(branching_dialog != null && (current_v.length() < 1 || stop_bypass)):
		if(!is_animatronic && !no_face_player):
			face_player()
		dialog_manager = dialog.instantiate()
		if(dialog_offset != null):
			dialog_manager.set_nudge_vector(dialog_offset)
		if(alt_dlg_bubble_path != ""):
			dialog_manager.set_alternate_bubble(alt_dlg_bubble_path)
		dialog_manager.set_speaker_node(self)
		add_child(dialog_manager)
		#if(dialog_offset != null):
			#dialog_manager.position = dialog_manager.position + dialog_offset
		if(shop != null):
			dialog_manager.set_shop(shop)
		var player_ref = get_tree().get_nodes_in_group("player")[0]
		player_ref.enter_dialog()
		dialog_manager.set_tree_and_start_dialog(branching_dialog)
		perceptions.in_dialog = true

func check_vision():
	if (_vision.is_colliding()):
			var detected_nodes: Array[Node] = []
			var iterator = 0
			while(iterator < _vision.get_collision_count()):
				var entity = _vision.get_collider(iterator)
				_vision.get
				if(entity != null ):
					detected_nodes.append(entity)
				iterator = iterator + 1
			perceptions.nodes_in_vision = detected_nodes

func check_hearing():
	var commotion_notice_distance = 300
	var commotions = get_tree().get_nodes_in_group("commotion")
	var nodes_in_hearing: Array[Node] = []
	for commotion in commotions:
		if (global_position.distance_to(commotion.global_position) < commotion_notice_distance):
			nodes_in_hearing.append(commotion)
	perceptions.nodes_in_hearing = nodes_in_hearing

func out_of_dialog():
	perceptions.in_dialog = false

func set_schedules_index(index : int):
	schedules_index = index
	update_stage_mark()

func get_schedules_index() -> int:
	return schedules_index

func set_schedules_key(key : String):
	var index = schedule_keys.find(key)
	set_schedules_index(index)

func get_schedules_key() -> String:
	return schedule_keys[schedules_index]

func update_line_of_sight_to_target():
	if(perceptions.target_obj != null):
		if(active_has_line_of_sight_to_object(perceptions.target_obj)):
			perceptions.target_pos = perceptions.target_obj.global_position
			perceptions.has_line_of_sight_to_target = true
		else:
			perceptions.has_line_of_sight_to_target = false

func active_has_line_of_sight_to_object(obj):
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(global_position,obj.global_position,ray_collision_mask,[self])
	var result = null
	if(space_state != null):
		result = space_state.intersect_ray(query)
	
	#_active_raycast.set_target_position(obj.global_position - _active_raycast.global_position)
	if(result && result.collider == obj):
		return true
	else:
		perceptions.nodes_in_vision.erase(obj)
		return false

func _on_set_ai_target(entity : Node):
	if(entity != null):
		perceptions.target_obj = entity
		update_line_of_sight_to_target()
		send_perceptions()
		perceptions.target_pos = perceptions.target_obj.global_position

func update_perceptions():
	perceptions.current_v = current_v
	if(!is_animatronic):
		perceptions.facing_dir = _character_base.get_facing_dir()
	perceptions.position = position
	perceptions.global_position = global_position
	perceptions.linear_velocity = linear_velocity
	perceptions.speed = linear_velocity.length()
	
	if(has_hearing):
		check_hearing()
	if(has_vision):
		update_vision()
		check_vision()
		update_line_of_sight_to_target()
	
	update_stage_mark()

func update_vision():
	match(_character_base.get_facing_dir()):
		direction.right:
			_vision.set_rotation_degrees(0) 
		direction.left:
			_vision.set_rotation_degrees(180)
		direction.up:
			_vision.set_rotation_degrees(270)
		direction.down:
			_vision.set_rotation_degrees(90)

func update_stage_mark():
	if(schedules.size() > 0):
		var time_keeper_ref = get_tree().get_first_node_in_group("time_keeper")
		if(time_keeper_ref != null):
			var current_schedule = schedules[schedules_index]
			var current_day_index = time_keeper_ref.get_day_of_week()
			var current_hour_index = time_keeper_ref.get_hour()
			var current_stage_mark = current_schedule.get_stage_mark(current_day_index,current_hour_index)
			perceptions.current_stage_mark = current_stage_mark
			update_branching_dialog()
		
func get_branching_dialog():
	return branching_dialog

func get_shop_manager():
	return shop

func speed():
	return linear_velocity.length()

func stop():
	current_v = perceptions.current_v * 0

func handle_passive_text():
	var passive_text = perceptions.current_stage_mark.get_passive_text()
	if(passive_text != "" &&
	global_position.distance_to(perceptions.current_stage_mark.global_position) < 8):
		var in_talk_radius = self.global_position.distance_to(player_ref.global_position) < talk_radius
		if(!player_ref.in_dialog && !talking && in_talk_radius && !has_talked):
			_on_make_comment(passive_text)
		elif (speech_instance != null && 
		player_ref.in_dialog || talking && speech_instance.ready_to_disappear):
			speech_instance.queue_free()
			talking = false
		
		if(!in_talk_radius):
			has_talked = false

func _on_make_comment(text : String):
	speech_instance = speech_bubble.instantiate()
	self.add_child(speech_instance)
	speech_instance.play_passive_text(text, voice)
	has_talked = true
	talking = true

func get_nearest_point_on_mesh(point : Vector2):
	var rid = _navigation_agent.get_navigation_map()
	if(NavigationServer2D.map_get_iteration_id(rid) > 0):
		return NavigationServer2D.map_get_closest_point(rid, point)
	return global_position

func exclaim():
	sound_player.stream = exclaim_sound
	sound_player.play()
	var exclaimBubble
	exclaimBubble = exclaim_bubble.instantiate()
	exclaimBubble.set_source_obj(perceptions.target_obj)
	self.add_child(exclaimBubble)

func _on_set_branching_dialog(tree : dialog_tree):
	branching_dialog = tree

func play_animation(name : String):
	_character_base.play_animation(name)

func animations_finished():
	if(is_animatronic): #this is only supported by animatronic bases
		return _character_base.animation_queue_empty()

func play_animations(animations: Array[String]):
	if(is_animatronic): #this is only supported by animatronic bases
		_character_base.play_animations(animations)

func _on_set_nav_target(pos : Vector2):
	perceptions.nav_target_reached = false
	_navigation_agent.target_position = get_nearest_point_on_mesh(pos)

func _on_turn_right():
	_character_base.turn_right()
	perceptions.facing_dir = _character_base.get_facing_dir()
	
func _on_turn_left():
	_character_base.turn_left()
	perceptions.facing_dir = _character_base.get_facing_dir()

#move mobster along A* navigation path towards navigation target
#and animate accordingly
func _on_advance_navigation(speed : int):
	if (!perceptions.nav_target_reached &&
	global_position.distance_to(_navigation_agent.target_position) > nav_target_reached_distance):
		var current_agent_position: Vector2 = global_position
		var next_path_position: Vector2 = _navigation_agent.get_next_path_position()
		current_v = current_agent_position.direction_to(next_path_position) * speed
	else:
		current_v = perceptions.current_v * 0
		perceptions.nav_target_reached = true
	#handle animation
	_character_base.face_to_vector(current_v)
	_character_base.animate_sprite_by_vector(current_v, (linear_velocity.length() >= top_speed))
	var base = 0.4
	var remainder = 0.6
	_character_base.set_animation_scale(base,remainder,perceptions.speed,top_speed)
	
	if(current_v.length() > 0):
		if(_character_base.get_base_current_frame() == 1 || _character_base.get_base_current_frame() == 3):
			if(can_play_footfall):
				footfall_player.play()
				can_play_footfall = false
		else:
			can_play_footfall = true

func _on_reach_stage_mark():
	update_branching_dialog()

func _on_leave_stage_mark():
	branching_dialog = null

func face_player():
	var vector_to_player = global_position.direction_to(player_ref.global_position)
	_character_base.face_to_vector(vector_to_player)

func _on_handle_behavior(behavior_directive : String):
	#alert passive NPC
	if(behavior_directive == alert_passive):
		if(self.global_position.distance_to(player_ref.global_position) < talk_radius):
			face_player()
		elif(perceptions.current_stage_mark.get_passive_face_dir() != ""):
			match(perceptions.current_stage_mark.get_passive_face_dir()):
				"up":
					_character_base.face_up()
				"down":
					_character_base.face_down()
				"left":
					_character_base.face_left()
				"right":
					_character_base.face_right()
		handle_passive_text()

func _on_body_entered(body : Node):
	if(body_enter_script_node != null):
		body_enter_script_node.run_script(body)

func get_save_dictionary() -> Dictionary:
	var save_tag : String = get_save_tag()
	var save_dictionary = {
		"type" : "npc",
		"save_tag" : get_save_tag(),
		#"pos_x" : global_position.x,
		#"pos_y" : global_position.y,
		"schedules_index" : int(schedules_index)
	}
	return save_dictionary

func get_ai_state():
	return _ai_state_machine.state.name

func transition_ai_state(state: String):
	_ai_state_machine.transition_to(state)

func teleport_and_update():
	if(schedules.size() > 0 && !exempt_from_npc_refresh):
		update_stage_mark()
		global_position = perceptions.current_stage_mark.global_position
		if(!is_animatronic):
			_on_set_nav_target(perceptions.current_stage_mark.global_position)
			current_v = current_v * 0
		var parent_node = perceptions.current_stage_mark.get_reparent_node()
		reparent(parent_node)
		immobilized = false
		_ai_state_machine.transition_to(perceptions.current_stage_mark.get_state())

func set_immobilized(input : bool):
	immobilized = input

func load_from_dictionary(load_dictionary : Dictionary):
	#global_position = Vector2(load_dictionary.get("pos_x"), load_dictionary.get("pos_y"))
	schedules_index = int(load_dictionary.get("schedules_index"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(!Engine.is_editor_hint()):
		update()
		send_perceptions()

func _physics_process(delta):
	if(!Engine.is_editor_hint()):
		if(!is_animatronic):
			if(!immobilized || perceptions.in_dialog):
				_character_base.face_to_vector(current_v)
				_character_base.animate_sprite_by_vector(current_v, (speed() >= top_speed))
			else:
				current_v = current_v * 0
			
			#apply velocity thru physics engine
			apply_force(current_v)
		
		if(current_v.length() < 1 &&
		branching_dialog != null &&
		!is_in_group("talkable")):
			add_to_group("talkable")
		elif(!current_v.length() < 1 ||
		branching_dialog == null &&
		is_in_group("talkable")):
			remove_from_group("talkable")
