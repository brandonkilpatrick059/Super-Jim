extends Node2D

var sound_player := AudioStreamPlayer.new()
@onready var _animated_sprite = $AnimatedSprite2D
@onready var _collision_shape = $StaticBody2D/CollisionShape2D
@onready var _static_body = $StaticBody2D
@onready var _area_2d = $Area2D

@export var opens_for_groups: Array[String]
@export var locked_hours : Array[bool] #should either be empty or size = 24

@export var parent_door : Node2D

@export var cannot_trap_player = false
@export var locked = false
@export var one_time_use = false

@export var does_not_open = false
@export var address : String = ""

@export var save_tag : String = ""

var time_keeper

var opened = false
var opening = false
var closing = false
var waiting_to_open = false
var waiting_to_close = false
var open_close_timer := Timer.new()
var open_close_time_secs = 0.2
var open_distance = 32

var last_frame_open = 0
var last_frame_close = 0

var dialog_offset #needed so delivery dialog doesn't throw errors

func get_save_tag() -> String:
	return save_tag

# Called when the node enters the scene tree for the first time.
func _ready():
	open_close_timer.one_shot = true
	add_child(open_close_timer)
	time_keeper = get_tree().get_first_node_in_group("time_keeper")
	last_frame_open = _animated_sprite.sprite_frames.get_frame_count("open")-1 
	last_frame_close = _animated_sprite.sprite_frames.get_frame_count("close")-1 
	if(self.is_in_group("delivery_door")):
		does_not_open = true

func get_save_dictionary() -> Dictionary:
	var save_dictionary = {
		"type" : "door",
		"save_tag" : get_save_tag(),
		"locked" : locked 
	}
	return save_dictionary

func load_from_dictionary(load_dictionary : Dictionary):
	locked = load_dictionary.get("locked")

func get_address():
	return address

func open():
	if(!opened):
		_animated_sprite.play("open")
		opening = true

func get_parent_door():
	return parent_door

func close():
	if(opened):
		_animated_sprite.play("close")
		closing = true
		if(one_time_use):
			opens_for_groups = []
			locked = true

func lock():
	locked = true

func unlock():
	locked = false

func get_opener_is_near() -> bool:
	var retVal = false
	var nodes_in_area : Array[Node2D] = _area_2d.get_overlapping_bodies()
	for group in opens_for_groups:
		for node in nodes_in_area:
			if(node.is_in_group(group)):
				retVal = true
	return retVal

#used so that a player doesn't get trapped behind a locked door
func player_is_behind_door():
	var player_ref = get_tree().get_first_node_in_group("player")
	var relative_position = global_position.y - player_ref.global_position.y
	var ret_val = false
	if(relative_position > 0):
		ret_val = true
	return ret_val

func _process(delta: float) -> void:
	#by default doors are prunable (will be removed from tree to save processor usage)
	#but doors which are saved/loaded from memory
	#are locked/unlocked while offscreen, which would not
	#be possible if they were pruned (removed from tree). So this code
	#enforces an exception for doors which are saved/loaded from memory
	if(!is_in_group("prunable") && save_tag == ""):
		add_to_group("prunable")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float):
	if(!does_not_open):
		var opener_is_near = false
		if(_area_2d.has_overlapping_bodies()):
			opener_is_near = get_opener_is_near()
		
		if(waiting_to_open):
			#opener has to stand near the door for a period of time for it to open
			if(!opened && opener_is_near):
				waiting_to_open = true
				open_close_timer.start((open_close_time_secs))
		else:
			#if that period of time has elapsed and the opener is still there, open
			if(open_close_timer.is_stopped()):
				if(opener_is_near):
					if(!locked || (locked && !cannot_trap_player && player_is_behind_door())):
						open()
				else:
					waiting_to_open = false
		
		if(waiting_to_close):
			#if that period of time has elapsed and the opener is still gone, close
			if(open_close_timer.is_stopped() && !opener_is_near):
				close()
			else: if(open_close_timer.is_stopped() && opener_is_near):
				waiting_to_close = false
		else:
			#if the opener leaves the door and it is open, it will start a timer to close itself
			if(opened && !opener_is_near):
				waiting_to_close = true
				open_close_timer.start((open_close_time_secs))
		
		#set lock by time using bool list locked_hours
		if(locked_hours.size() == 24):
			if(locked_hours[time_keeper.clock]):
				locked = true
			else: locked = false
		
		if(opening && _animated_sprite.frame == last_frame_open):
			opened = true
			opening = false
			_animated_sprite.play(("opened"))
			_collision_shape.set_deferred("disabled", true)
		elif(closing && _animated_sprite.frame == last_frame_close):
			opened = false
			closing = false
			_animated_sprite.play(("closed"))
			_collision_shape.set_deferred("disabled", false)
