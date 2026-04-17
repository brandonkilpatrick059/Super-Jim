extends RigidBody2D

@onready var _collision_shape = $CollisionShape2D
@onready var sprite = $sprite
@onready var _occluder = $occluder
@export var has_home = true
@export var force_factor = 100
@export var sleep_if_occluded = true

var picked_up = false
var will_pickup = false
var showing_arrow = false
var distance_for_pickup = 100
var spark = preload("res://effects/spark.tscn")
var arrow_instance = null 
@export var script_node_on_pickup : Node = null

var sound_player := AudioStreamPlayer2D.new()

var should_reset = false
var new_position = Vector2(0, 0)

var throw_force = Vector2(0, 0)
var thrown = false

var pickup_actor_ref : Node = null

var base_offset = 24
var y_sort_offset = 15
var original_offset : Vector2

var spark_time_secs :float = 1.5 #this actually mainly determines falling now
var timer_spark := Timer.new()
var can_spark = false

var local_collision_pos = Vector2(0,0)
var timer_fall := Timer.new()
var timer_fall_step = 0.05
var falling = false
var current_scale = 1
var scale_step = 0.05

var prop_home : Vector2 = Vector2(0,0)
var return_home_distance = 600

signal spark_collide()
signal signal_picked_up()
signal destroy_self()
signal on_use_item()

var in_falling_zone : bool = false

var original_parent = null

var fall_handler = null

# Called when the node enters the scene tree for the first time.
func _ready():
	original_offset = sprite.offset
	timer_spark.one_shot = true
	add_child(timer_spark)
	timer_fall.one_shot = true
	add_child(timer_fall)
	sound_player.max_distance = 500
	sound_player.bus = "Effects"
	add_child(sound_player)
	prop_home = global_position
	original_parent = get_parent()
	fall_handler = load("res://entities/props/dynamic props/props_dynamic_pickupable/fall_handler.tscn").instantiate()
	add_child(fall_handler)

#func set_physics_pos(vector2):
	#should_reset = true
	#new_position = vector2

func is_picked_up():
	return picked_up

func throw(dir, offset : Vector2 = Vector2(0,0)):
	if(picked_up):
		sprite.offset = original_offset
		thrown = true
		picked_up = false
		reparent(pickup_actor_ref.get_parent())
		_collision_shape.disabled = false
		timer_spark.start(0.5)
		can_spark = true
		match(dir):
			direction.left:
				throw_force = Vector2(-force_factor,0)
				global_position = pickup_actor_ref.global_position + Vector2(-base_offset, 0) + offset
				#set_physics_pos(pickup_actor_ref.global_position + Vector2(-base_offset, 0) + offset)
			direction.right:
				throw_force = Vector2(force_factor,0)
				global_position = pickup_actor_ref.global_position + Vector2(base_offset, 0) + offset
				#set_physics_pos(pickup_actor_ref.global_position + Vector2(base_offset, 0) + offset)
			direction.up:
				throw_force = Vector2(0,-force_factor)
				global_position = pickup_actor_ref.global_position + Vector2(0, -base_offset) + offset
				#set_physics_pos(pickup_actor_ref.global_position + Vector2(0, -base_offset) + offset)
			direction.down:
				throw_force = Vector2(0,force_factor)
				global_position = pickup_actor_ref.global_position + Vector2(0, base_offset) + offset
				#set_physics_pos(pickup_actor_ref.global_position + Vector2(0, base_offset) + offset)

func throw_bypass_pickup(dir, actor_ref):
	picked_up = true
	pickup_actor_ref = actor_ref
	throw(dir)

func pick_up(actor_ref : Node):
	sprite.offset = Vector2(0,-y_sort_offset)
	_collision_shape.disabled = true
	pickup_actor_ref = actor_ref
	global_position = pickup_actor_ref.global_position
	reparent(actor_ref)
	picked_up = true
	will_pickup = false
	signal_picked_up.emit()
	if(script_node_on_pickup != null):
		script_node_on_pickup.run_script()

func put_down(dir, offset : Vector2 = Vector2(0,0)):
	if(picked_up):
		sprite.offset = original_offset
		picked_up = false
		reparent(pickup_actor_ref.get_parent())
		_collision_shape.disabled = false
		match(dir):
			direction.left:
				throw_force = Vector2(-force_factor,0)
				global_position = pickup_actor_ref.global_position + Vector2(-base_offset, 0) + offset
				#set_physics_pos(pickup_actor_ref.global_position + Vector2(-base_offset, 0) + offset)
			direction.right:
				throw_force = Vector2(force_factor,0)
				global_position = pickup_actor_ref.global_position + Vector2(base_offset, 0) + offset
				#set_physics_pos(pickup_actor_ref.global_position + Vector2(base_offset, 0) + offset)
			direction.up:
				throw_force = Vector2(0,-force_factor)
				global_position = pickup_actor_ref.global_position + Vector2(0, -base_offset) + offset
				#set_physics_pos(pickup_actor_ref.global_position + Vector2(0, -base_offset) + offset)
			direction.down:
				throw_force = Vector2(0,force_factor)
				global_position = pickup_actor_ref.global_position + Vector2(0, base_offset) + offset
				#set_physics_pos(pickup_actor_ref.global_position + Vector2(0, base_offset) + offset)


func set_will_pickup_false():
	will_pickup = false

func return_to_home():
	global_position = prop_home
	#set_physics_pos(prop_home)
	_collision_shape.disabled = false
	reparent(original_parent)
	linear_velocity = Vector2(0,0)
	falling = false
	if(script_node_on_pickup != null):
		script_node_on_pickup.run_return_script()

func use_item():
	on_use_item.emit()

func _physics_process(delta):
	fall_handler.global_position = global_position
	if(!falling && timer_spark.is_stopped() && in_falling_zone):
		_collision_shape.disabled = true
		falling = true                                                                                                                                                                    
		timer_fall.start(timer_fall_step)
		linear_velocity = Vector2(0,0)
	if(picked_up):
		global_position = (pickup_actor_ref.global_position + Vector2(0, -base_offset+y_sort_offset))
	elif(falling && timer_fall.is_stopped()):
		timer_fall.start(timer_fall_step)
		if(current_scale - scale_step > 0):
			current_scale = current_scale - scale_step
			sprite.scale = Vector2(current_scale, current_scale)
			#linear_velocity = linear_velocity + Vector2(0,50)
		else:
			if(is_in_group("pizza")):
				destroy_self.emit()
			else:
				if(has_home):
					return_to_home()
				else:
					queue_free()
	elif(global_position != prop_home && 
	_occluder != null && 
	_occluder.is_occluding):
		sleeping = true
		return_to_home()
	elif(_occluder != null && !_occluder.is_occluding):
		sleeping = false
	if(current_scale < 1 && !falling && timer_fall.is_stopped()):
		if(current_scale + scale_step < 1):
			current_scale = current_scale + scale_step
		else:
			current_scale  = 1
		sprite.scale = Vector2(current_scale, current_scale)

func enter_fall_zone():
	if(!is_picked_up()):
		in_falling_zone = true

func exit_fall_zone():
	if(!is_picked_up()):
		in_falling_zone = false

func _integrate_forces(state):
	if(state.get_contact_count() >= 1):  #this check is needed or it will throw errors 
		local_collision_pos = state.get_contact_local_position(0)
		if(!timer_spark.is_stopped() && can_spark && 
		!state.get_contact_collider_object(0).is_in_group("player")):
			can_spark = false
			var nSpark = spark.instantiate()
			get_parent().add_child(nSpark)
			nSpark.global_position = local_collision_pos
			sound_player.stream = load("res://audio/soundFX/bigCollide.wav")
			sound_player.play()
			spark_collide.emit()
			
	#if should_reset:
		#should_reset = false
		#state.transform.origin = new_position
	if thrown:
		state.apply_central_impulse(throw_force)
		thrown = false
