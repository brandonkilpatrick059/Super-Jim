@tool
extends RigidBody2D

var sound_player := AudioStreamPlayer2D.new()

var blood = preload("res://effects/blood.tscn")
var question_bubble = preload("res://entities/characters/NPC/mobsters/communication/question.tscn")
var pizza_bubble = preload("res://entities/characters/NPC/mobsters/communication/pizza_bubble.tscn")
var exclaim_bubble = preload("res://entities/characters/NPC/mobsters/communication/exclaim.tscn")
var exclaim_bubble_blu = preload("res://entities/characters/NPC/mobsters/communication/exclaim_blu.tscn")
var exclaim_bubble_red = preload("res://entities/characters/NPC/mobsters/communication/exclaim_red.tscn")
var flag_bubble_blu = preload("res://entities/characters/NPC/mobsters/communication/flag_blu.tscn")
var flag_bubble_red = preload("res://entities/characters/NPC/mobsters/communication/flag_red.tscn")
var die_skull = preload("res://effects/kill_skull.tscn")
var red_bullet = preload("res://entities/characters/NPC/mobsters/red_bullet.tscn")
var blu_bullet = preload("res://entities/characters/NPC/mobsters/blu_bullet.tscn")
var blu_bomb = preload("res://entities/characters/NPC/mobsters/blu_bomb.tscn")
var red_bomb = preload("res://entities/characters/NPC/mobsters/red_bomb.tscn")
var blu_base = preload("res://sprites/spritesheets/spriteframes/characters/base/blu_mobster_base.tres")
var red_base = preload("res://sprites/spritesheets/spriteframes/characters/base/red_mobster_base.tres")
var red_hat = preload("res://sprites/spritesheets/spriteframes/characters/hat/cowboy_hat_1.tres")
var red_bandit_hat = preload("res://sprites/spritesheets/spriteframes/characters/hat/red_bandit_mask.tres")
var blue_top = preload("res://sprites/spritesheets/spriteframes/characters/top/biker_vest_1.tres")
var blue_bandit_hat = preload("res://sprites/spritesheets/spriteframes/characters/hat/blu_bandit_mask.tres")

@onready var _navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var _head_collider = $head_shape
@onready var _body_collider = $CollisionShape2D
@onready var _spark_detector : Area2D = $spark_detector

@export var current_patrol_point :Node2D = null

#mobster team
const team_red = "red"
const team_blu = "blu"
@export var team = team_red
var opposing_team 
var is_bandit = false

#perceptors
@onready var _passive_raycast: RayCast2D = $passive_raycast
@onready var _active_raycast: RayCast2D = $active_raycast
@onready var _reactive_raycast: RayCast2D = $reactive_raycast
@onready var _vision = $vision
@onready var _shadow = $shadow

#character composition
@onready var _character_base = $character_base
@export var base_spriteframes : SpriteFrames
@export var hat_spriteframes : SpriteFrames
@export var top_spriteframes : SpriteFrames
@export var bottom_spriteframes : SpriteFrames
var start_facing_dir = direction.right

var current_v = Vector2(0,0) #force applied this physics frame

#data type representing mobster's knowledge of itself and its surroundings
var perceptions: MobsterPerceptions = MobsterPerceptions.new()

#state machine reference
@onready var _ai_state_machine = $ai_state_machine

var random = RandomNumberGenerator.new()

const top_speed = 125000
const nav_target_reached_distance = 32 #distance at which nav target is considered reached
const nav_path_resolution = 4

const bandit_max_hit_points = 6
const max_hit_points = 3
var hit_points = 0

var invincibility_timer = Timer.new()
var damage_collision_layer : int
var is_invincible = false
var holding_object = false
var held_obj : Node

var offset_vector : Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	set_up_character_base()
	if(!Engine.is_editor_hint()):
		set_up_sound_player()
		set_up_nav_agent()
		set_up_mobster_team()	
		update_perceptions()
		send_perceptions()
		
		invincibility_timer.one_shot = true
		add_child(invincibility_timer)
	
	#for updating character composition in the editor
	if(Engine.is_editor_hint()):
		queue_redraw()

func make_bandit():
	is_bandit = true
	if(team == team_red):
		hat_spriteframes = red_bandit_hat
	else:
		hat_spriteframes = blue_bandit_hat

	_character_base.set_spriteframes(base_spriteframes,
	hat_spriteframes,
	top_spriteframes,
	bottom_spriteframes)
	
	hit_points = bandit_max_hit_points
	add_to_group("bandit")
	perceptions.is_bandit = is_bandit

func set_team(team_name : String):
	team = team_name

func set_up_character_base():
	if(team == team_red):
		base_spriteframes = red_base
		hat_spriteframes = red_hat
	else: if(team == team_blu):
		base_spriteframes = blu_base
		top_spriteframes = blue_top
	_character_base.set_facing_dir(start_facing_dir)
	_character_base.set_spriteframes(base_spriteframes,
	hat_spriteframes,
	top_spriteframes,
	bottom_spriteframes)
	_character_base.stand_dir("")

func set_up_nav_agent():
	#nav agent setup stuff
	_navigation_agent.path_desired_distance = 4.0
	_navigation_agent.target_desired_distance = nav_target_reached_distance

func set_up_sound_player():
	sound_player.max_distance = 500
	sound_player.attenuation = 2
	sound_player.bus = "Effects"
	add_child(sound_player)

func set_up_mobster_team():
	add_to_group(team)
	if(team == team_red):
		opposing_team = team_blu
		damage_collision_layer = 2
		set_collision_layer_value(damage_collision_layer,true) #base collision layer
		set_collision_layer_value(10,true) #collision layer for raycasts
		_passive_raycast.set_collision_mask_value(11,true)
		_active_raycast.set_collision_mask_value(11,true)
		_vision.set_collision_mask_value(11,true)
	else: if (team == team_blu):
		opposing_team = team_red
		damage_collision_layer = 7
		set_collision_layer_value(damage_collision_layer,true)#base collision layer
		set_collision_layer_value(11,true) #collision layer for raycasts
		_passive_raycast.set_collision_mask_value(10,true)
		_active_raycast.set_collision_mask_value(10,true)
		_vision.set_collision_mask_value(10,true)
	perceptions.team = team
	perceptions.opposing_team = opposing_team

	hit_points = max_hit_points

#################################################################
#PERCEPTIONS- functions which deal with the mobster's perceptions
#################################################################

func send_perceptions():
	if(_ai_state_machine != null):
		_ai_state_machine.receive_perceptions(perceptions)

func update_line_of_sight_to_target():
	if(perceptions.target_obj != null):
		if(active_has_line_of_sight_to_object(perceptions.target_obj)):
			perceptions.target_pos = perceptions.target_obj.global_position
			perceptions.has_line_of_sight_to_target = true
		else:
			perceptions.has_line_of_sight_to_target = false
		
		#separate raycasts and perception var for checking line-of-sight
		#to reactive props (like the Pizza)
		#we do this so that items do not block sightline checks for
		#combat targets
		if(reactive_has_line_of_sight_to_object(perceptions.target_obj)):
			perceptions.target_pos = perceptions.target_obj.global_position
			perceptions.reactive_has_line_of_sight_to_target = true
		else:
			perceptions.reactive_has_line_of_sight_to_target = false

func update_perceptions():
	perceptions.current_v = current_v
	perceptions.facing_dir = _character_base.get_facing_dir()
	perceptions.position = position
	perceptions.linear_velocity = linear_velocity
	perceptions.speed = linear_velocity.length()
	perceptions.hit_points = hit_points
	perceptions.invincible = is_invincible
	perceptions.holding_object = holding_object
	
	update_line_of_sight_to_target()
	
	check_vision()
	check_hearing()
	detect_sparks()

	#clean out null nodes from sparks queue-freeing
	var iter = 0
	while iter < len(perceptions.colliding_nodes):
		if not is_instance_valid(perceptions.colliding_nodes[iter]):
			perceptions.colliding_nodes.remove_at(iter)
		else:
			iter += 1
	
	#check if currently playing one-shot animation has ended
	if(perceptions.one_shot_animating &&
	_character_base.get_base_current_frame() == _character_base.get_base_animation_framecount() - 1):
		perceptions.one_shot_animating = false


func _on_body_entered(body: Node):
	perceptions.colliding_nodes.append(body)

func _on_body_exited(body: Node):
	var node_index = perceptions.colliding_nodes.find(body)
	perceptions.colliding_nodes.remove_at(node_index)

#we need a separate passive raycast for use with regular vision checking
#or else there will be race conditions fighting over the ray-cast as we
#check for line of sight 
func passive_has_line_of_sight_to_object(obj):
	_passive_raycast.set_target_position(obj.global_position - _passive_raycast.global_position)
	if(_passive_raycast.is_colliding() && _passive_raycast.get_collider() == obj):
		return true
	else:
		perceptions.nodes_in_vision.erase(obj)
		return false

func passive_has_line_of_sight_to_point(point: Vector2):
	_passive_raycast.set_target_position(point - _passive_raycast.global_position)
	if(!_passive_raycast.is_colliding()):
		return true
	else:
		return false

func active_has_line_of_sight_to_object(obj):
	_active_raycast.set_target_position(obj.global_position - _active_raycast.global_position)
	if(_active_raycast.is_colliding() && _active_raycast.get_collider() == obj):
		return true
	else:
		perceptions.nodes_in_vision.erase(obj)
		return false

func active_has_line_of_sight_to_point(point: Vector2):
	_active_raycast.set_target_position(point)
	if(!_active_raycast.is_colliding()):
		return true
	else:
		return false

func reactive_has_line_of_sight_to_object(obj):
	_reactive_raycast.set_target_position(obj.global_position - _reactive_raycast.global_position)
	if(_reactive_raycast.is_colliding() && _reactive_raycast.get_collider() == obj):
		return true
	else:
		perceptions.nodes_in_vision.erase(obj)
		return false

func check_vision():
	if (_vision.is_colliding()):
			var detected_nodes: Array[Node] = []
			var iterator = 0
			while(iterator < _vision.get_collision_count()):
				var entity = _vision.get_collider(iterator)
				if(entity != null && 
				passive_has_line_of_sight_to_object(entity)):
					detected_nodes.append(entity)
				iterator = iterator + 1
			perceptions.nodes_in_vision = detected_nodes

func check_hearing():
	var commotion_notice_distance = 400
	var commotions = get_tree().get_nodes_in_group("commotion")
	var nodes_in_hearing: Array[Node] = []
	for commotion in commotions:
		if (global_position.distance_to(commotion.global_position) < commotion_notice_distance):
			nodes_in_hearing.append(commotion)
	perceptions.nodes_in_hearing = nodes_in_hearing

func detect_sparks():
	var bodies_in_detector = _spark_detector.get_overlapping_bodies()
	for body in bodies_in_detector:
		if(is_instance_valid(body) &&
			body.is_in_group("spark") &&
			body not in perceptions.colliding_nodes):
				perceptions.colliding_nodes.append(body)

###################################################################################################
#ACTIONS- signal functions and helpers that cause the mobster to take some action in the game world
###################################################################################################

func set_holding_object(is_holding):
	holding_object = is_holding
	_character_base.set_arms_raised(is_holding)

func go_invincible():
	invincibility_timer.start(1.5)
	_character_base.start_flashing()
	is_invincible = true
	set_collision_layer_value(damage_collision_layer,false)

func go_vincible():
	_character_base.stop_flashing()
	is_invincible = false
	set_collision_layer_value(damage_collision_layer,true)

func has_clear_shot(point : Vector2):
	var bounds = 24
	if((point.x < perceptions.target_pos.x + bounds && point.x > perceptions.target_pos.x - bounds) ||
	(point.y < perceptions.target_pos.y + bounds && point.y > perceptions.target_pos.y - bounds)):
		return true
	else:
		return false

func get_nearest_point_on_mesh(point : Vector2):
	var rid = _navigation_agent.get_navigation_map()
	return NavigationServer2D.map_get_closest_point(rid, point)

#returns a list of oints in 8 cardinal directions, points 
#fanning out at an interval of step_distance for num_steps intervals
func get_stepped_points_from_pos(pos: Vector2, num_steps, step_distance) -> Array[Vector2]:
	var iterator = 1
	var points : Array[Vector2] = []
	while(iterator <= num_steps):
		var step = step_distance * iterator
		var north = Vector2(pos.x, pos.y - step)
		points.append(north)
		var northEast = Vector2(pos.x + step, pos.y - step)
		points.append(northEast)
		var east = Vector2(pos.x + step, pos.y)
		points.append(east)
		var southEast = Vector2(pos.x + step, pos.y + step)
		points.append(southEast)
		var south = Vector2(pos.x, pos.y + step)
		points.append(south)
		var soutWest = Vector2(pos.x - step, pos.y + step)
		points.append(soutWest)
		var west = Vector2(pos.x - step, pos.y)
		points.append(west)
		var northWest = Vector2(pos.x + step, pos.y)
		points.append(northWest)
		iterator = iterator + 1
	return points

#to prevent mobs from overlapping, we adjust every nav point to include some randomness
func get_adjusted_point(pos: Vector2) -> Vector2:
	var distance_step = 3
	var num_steps = 16
	var points = get_stepped_points_from_pos(pos, num_steps, distance_step)
	var adjusted_point = points[random.randi_range(0,points.size() -1 )]
	adjusted_point = get_nearest_point_on_mesh(adjusted_point)
	return adjusted_point

func get_strafe_point():
	var strafe_distance_step = 4
	var strafe_steps = 32
	var points = get_stepped_points_from_pos(global_position, strafe_steps, strafe_distance_step)
	
	var valid_points = []
	for point in points:
		if(has_clear_shot(point)):
			valid_points.append(point)
			
	if(valid_points.size() > 0):
		var strafe_point = valid_points[random.randi_range(0,valid_points.size() -1 )]
		strafe_point = get_nearest_point_on_mesh(strafe_point)
		return strafe_point
	else:
		return global_position

func _on_adjust_offset(adjustment : Vector2):
	var current_offset = _character_base.get_offset()
	_character_base.adjust_offset(current_offset + adjustment)
	position += -adjustment
	var children = get_children()
	for child in children:
		if(child.is_in_group("exclaim") ||
		child.is_in_group("question") ||
		child.is_in_group("pizza_bubble") ||
		child.is_in_group("flag")):
			child.position += adjustment
	_shadow.offset += adjustment
	offset_vector = adjustment

func _on_pick_up(pick_up_obj : Node):
	if(!holding_object):
		sound_player.stream = load("res://audio/soundFX/pickup.wav")
		sound_player.play()
		pick_up_obj.pick_up(self)
		held_obj = pick_up_obj
		set_holding_object(true)

func _on_put_down():
	if(holding_object):
		sound_player.stream = load("res://audio/soundFX/putdown.wav")
		sound_player.play()
		held_obj.put_down(direction.get_opposite(_character_base.get_facing_dir()))
		held_obj = null
		set_holding_object(false)

func _put_down_and_destroy():
	if(holding_object):
		held_obj.put_down(direction.get_opposite(_character_base.get_facing_dir()))
		held_obj.queue_free()
		set_holding_object(false)
		var player_ref = get_tree().get_first_node_in_group("player")
		player_ref._on_pizza_lost()

func _on_queue_free():
	queue_free()

func _on_disable_all_collision():
	_on_disable_head_collider()
	_body_collider.disabled = true

func _on_enable_all_collision():
	_on_enable_head_collider()
	_body_collider.disabled = false

func _on_reduce_hit_points():
	go_invincible()
	hit_points -= 1

func _on_add_hit_point():
	hit_points += 1

func heal_to_max():
	if(is_bandit):
		hit_points = bandit_max_hit_points
	else:
		hit_points = max_hit_points

func _on_set_strafe_point():
	_on_set_unadjusted_nav_target(get_strafe_point())

func _on_create_bullet(create_pos: Vector2, rotation_deg):
	var new_bullet
	if(team == team_red):
		new_bullet = red_bullet.instantiate()
	else: if(team == team_blu):
		new_bullet = blu_bullet.instantiate()
	new_bullet.set_source_obj(self)
	get_parent().add_child(new_bullet)
	
	new_bullet.rotation_degrees = rotation_deg
	new_bullet.position = create_pos
	new_bullet.apply_velocity()
	new_bullet.create_spark_benign() #muzzle flash
	sound_player.stream = load("res://audio/soundFX/gunshot.wav")
	sound_player.play()

func _on_create_bomb():
	var new_bomb
	var trajectory : Vector2
	var width = 0.5
	if(team == team_red):
		new_bomb = red_bomb.instantiate()
	else: if(team == team_blu):
		new_bomb = blu_bomb.instantiate()
	if(perceptions.facing_dir == direction.right):
		var y_factor = random.randf_range(-width,width)
		trajectory = Vector2(1, y_factor)
	elif(perceptions.facing_dir == direction.left):
		var y_factor = random.randf_range(-width,width)
		trajectory = Vector2(-1, y_factor)
	elif(perceptions.facing_dir == direction.up):
		var x_factor = random.randf_range(-width,width)
		trajectory = Vector2(x_factor, -1)
	elif(perceptions.facing_dir == direction.down):
		var x_factor = random.randf_range(-width,width)
		trajectory = Vector2(x_factor, 1)
	sound_player.stream = load("res://audio/soundFX/throw_bomb.wav")
	sound_player.play()
	new_bomb.set_trajectory(trajectory)
	new_bomb.set_source_obj(self)
	get_parent().add_child(new_bomb)
	new_bomb.position = position

func _on_set_nav_target(pos : Vector2):
	perceptions.nav_target_reached = false
	_navigation_agent.target_position = get_adjusted_point(pos)

func _on_set_unadjusted_nav_target(pos : Vector2):
	perceptions.nav_target_reached = false
	_navigation_agent.target_position = get_nearest_point_on_mesh(pos)

#move mobster along A* navigation path towards navigation target
#and animate accordingly
func _on_advance_navigation(speed : int):
	if (!perceptions.nav_target_reached &&
	global_position.distance_to(_navigation_agent.target_position) >= nav_target_reached_distance):
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

func _on_turn_right():
	_character_base.turn_right()
	perceptions.facing_dir = _character_base.get_facing_dir()
	
func _on_turn_left():
	_character_base.turn_left()
	perceptions.facing_dir = _character_base.get_facing_dir()

func _on_stand_dir(stand : String):
	if(stand == ""):
		_character_base.stand_dir(perceptions.facing_dir)
		_character_base.set_animation_scale_ratio(1)
	else:
		_character_base.stand_dir(stand)
		_character_base.set_animation_scale_ratio(1)

func _on_play_one_shot_animation(animation_name: String):
	if(perceptions.one_shot_animating == false):
		perceptions.one_shot_animating = true
		_character_base.play_animation(animation_name)

func _on_play_animation(animation_name: String):
	_character_base.play_animation(animation_name)

func _on_disable_head_collider():
	_head_collider.disabled = true

func _on_enable_head_collider():
	_head_collider.disabled = false

func _on_stop_motion():
	_character_base.set_animation_scale_ratio(1)
	current_v = Vector2(0,0)

func _on_play_sound(resource_name: String):
	sound_player.stream = load(resource_name)
	sound_player.play()

func _on_question_bubble():
	sound_player.stream = load("res://audio/soundFX/voice/sine_voice/1.wav")
	sound_player.play()
	var questionBubble = question_bubble.instantiate()
	self.add_child(questionBubble)

func _on_pizza_bubble():
	sound_player.stream = load("res://audio/soundFX/voice/sine_voice/1.wav")
	sound_player.play()
	var pizzaBubble = pizza_bubble.instantiate()
	self.add_child(pizzaBubble)

func _on_blood():
	var blood = blood.instantiate()
	self.add_child(blood)
	blood.position += offset_vector

func _on_die_skull():
	sound_player.stream = load("res://audio/soundFX/voice/low_sine_voice/1.wav")
	sound_player.play()
	var skull = die_skull.instantiate()
	self.add_child(skull)

func _on_flag_bubble():
	sound_player.stream = load("res://audio/soundFX/horn.wav")
	sound_player.play()
	var flagBubble
	if(team == team_blu):
		flagBubble = flag_bubble_blu.instantiate()
	else:
		flagBubble = flag_bubble_red.instantiate()
	flagBubble.set_source_obj(self)
	self.add_child(flagBubble)

func _on_exclaim_bubble():
	sound_player.stream = load("res://audio/soundFX/alert.wav")
	sound_player.play()
	var exclaimBubble
	if(perceptions.target_obj != null && 
	perceptions.target_obj.is_in_group("player")):
		exclaimBubble = exclaim_bubble.instantiate()
	else:
		if(team == team_blu):
			exclaimBubble = exclaim_bubble_red.instantiate()
		else:
			exclaimBubble = exclaim_bubble_blu.instantiate()
	exclaimBubble.set_source_obj(perceptions.target_obj)
	self.add_child(exclaimBubble)

func _on_set_ai_target_position():
	perceptions.target_pos = perceptions.target_obj.global_position

func _on_set_ai_target(entity : Node):
	if(entity != null):
		perceptions.target_obj = entity
		update_line_of_sight_to_target()
		send_perceptions()
		perceptions.target_pos = perceptions.target_obj.global_position
	else:
		#if no entity is given as target, 
		#select random enemy mob in line of sight
		var mobsters = get_tree().get_nodes_in_group("mobster")
		perceptions.target_obj = null
		for mob in mobsters:
			if mob.is_in_group(opposing_team) && active_has_line_of_sight_to_object(mob):
				perceptions.target_obj = mob
				update_line_of_sight_to_target()
				send_perceptions()
				perceptions.target_pos = perceptions.target_obj.global_position

func _on_face_ai_target_pos():
	var vector_to_target = global_position.direction_to(perceptions.target_pos)
	_character_base.face_to_vector(vector_to_target)
	perceptions.facing_dir = _character_base.get_facing_dir()

func _on_face_pos(pos : Vector2):
	var vector_to_target = global_position.direction_to(pos)
	_character_base.face_to_vector(vector_to_target)
	perceptions.facing_dir = _character_base.get_facing_dir()

##########################################################################################
#MAINTENENCE- functions that maintain the mobster's physical and observational consistency
##########################################################################################

func update():
	update_vision()
	update_perceptions()
	if(is_invincible && invincibility_timer.is_stopped()):
		go_vincible()

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

##############
#PROCESS STUFF
##############

func _physics_process(delta):
	if(!Engine.is_editor_hint()):
		update()
		send_perceptions()
		#apply velocity thru physics engine
		apply_force(current_v)
		var mobs = get_tree().get_nodes_in_group("mobster")
