@tool
extends Node2D
@onready var _base_sprite :AnimatedSprite2D = $base_sprite
@onready var _hat = $hat
@onready var _headphones = $headphones
@onready var _accessory = $accessory
@onready var _top = $top
@onready var _bottom = $bottom
@export var base_spriteframes : SpriteFrames = null
@export var hat_spriteframes : SpriteFrames = null
@export var top_spriteframes : SpriteFrames = null
@export var bottom_spriteframes : SpriteFrames = null
var arms_raised = false
var flashing = false
var is_visible = true

var flashing_timer = Timer.new() 

#current facing direction
var facing_dir = direction.right

func set_arms_raised(raised):
	arms_raised = raised

func get_facing_dir():
	return facing_dir

func face_up():
	facing_dir = direction.up

func face_down():
	facing_dir = direction.down
	
func face_left():
	facing_dir = direction.left

func face_right():
	facing_dir = direction.right

func get_base_current_animation():
	return _base_sprite.get_animation()

func set_facing_dir(facingDir):
	facing_dir = facingDir

func get_base_current_frame():
	return _base_sprite.frame

func get_offset() -> Vector2:
	return _base_sprite.offset

func adjust_offset(new_offset: Vector2):
	_base_sprite.offset = new_offset
	_headphones.offset = new_offset
	_accessory.offset = new_offset
	_hat.offset = new_offset
	_top.offset = new_offset
	_bottom.offset = new_offset

func get_base_animation_framecount(animation_name: String = ""):
	var base_animation_framecount
	if(animation_name == ""):
		base_animation_framecount = _base_sprite.sprite_frames.get_frame_count(get_base_current_animation())
	else:
		base_animation_framecount = _base_sprite.sprite_frames.get_frame_count(animation_name)
	return base_animation_framecount

func play_animation(animation: String):
	if(_base_sprite.animation != animation):
		if(_base_sprite.sprite_frames != null):
			_base_sprite.play(animation)
		if(_headphones.sprite_frames != null):
			_headphones.play(animation)
		if(_accessory.sprite_frames != null):
			_accessory.play(animation)
		if(_hat.sprite_frames != null):
			_hat.play(animation)
		if(_top.sprite_frames != null):
			_top.play(animation)
		if(_bottom.sprite_frames != null):
			_bottom.play(animation)

func set_frames(frame: int):
	if(_base_sprite.sprite_frames != null):
		_base_sprite.frame = frame
	if(_headphones.sprite_frames != null):
		_headphones.frame = frame
	if(_accessory.sprite_frames != null):
		_accessory.frame = frame
	if(_hat.sprite_frames != null):
		_hat.frame = frame
	if(_top.sprite_frames != null):
		_top.frame = frame
	if(_bottom.sprite_frames != null):
		_bottom.frame = frame

func set_speed_scales(scale):
	if(_base_sprite.sprite_frames != null):
		_base_sprite.set_speed_scale(scale)
	if(_headphones.sprite_frames != null):
		_headphones.set_speed_scale(scale)
	if(_accessory.sprite_frames != null):
		_accessory.set_speed_scale(scale)
	if(_hat.sprite_frames != null):
		_hat.set_speed_scale(scale)
	if(_top.sprite_frames != null):
		_top.set_speed_scale(scale)
	if(_bottom.sprite_frames != null):
		_bottom.set_speed_scale(scale)

func play_animation_frame(animation : String, frame : int):
	play_animation(animation)
	set_speed_scales(0.0)
	set_frames(frame)

func stand_dir(direction):
	if(direction != ""):
		facing_dir = direction
	var animation = str("stand_",facing_dir)
	if(arms_raised):
		animation = str(animation,"_arms")
	play_animation(animation)

func synch_animations():
	_base_sprite.frame = 0
	_headphones.frame = 0
	_accessory.frame = 0
	_hat.frame = 0
	_top.frame = 0
	_bottom.frame = 0

func walk_dir(direction):
	if(direction != ""):
		facing_dir = direction
	var animation = str("walk_",facing_dir)
	if(arms_raised):
		animation = str(animation,"_arms")
	play_animation(animation)

func walk_dir_frame(direction, frame : int):
	if(direction != ""):
		facing_dir = direction
	var animation = str("walk_",facing_dir)
	if(arms_raised):
		animation = str(animation,"_arms")
	play_animation_frame(animation,frame)

func set_all_materials(material):
	if(_base_sprite.sprite_frames != null):
		_base_sprite.set_material(material)
	if(_headphones.sprite_frames != null):
		_headphones.set_material(material)
	if(_accessory.sprite_frames != null):
		_accessory.set_material(material)
	if(_hat.sprite_frames != null):
		_hat.set_material(material)
	if(_top.sprite_frames != null):
		_top.set_material(material)
	if(_bottom.sprite_frames != null):
		_bottom.set_material(material)

#sets the facing_dir based on the given vector
func face_to_vector(vector):
	if(abs(vector.x) >= abs(vector.y)): 
		if(vector.x > 0):
			facing_dir = direction.right
		else: if (vector.x < 0):
			facing_dir =  direction.left
	#movement is greater on the y axis
	else: if (abs(vector.x) <= abs(vector.y)): 
		if(vector.y > 0):
			facing_dir = direction.down
		else: if (vector.y < 0):
			facing_dir = direction.up

#animate sprite based on a given vectors and its magnitude
func animate_sprite_by_vector(in_vector :Vector2, walk_override := false):
	#in_vector doesn't affect facing_dir???
	#it really should. I thought it did.
	#in practice, it seems to.
	#idk how
	#but this code is working and I'm too scared to touch it...
	if(in_vector.length() > 0 || walk_override):
		walk_dir(facing_dir)
	else: 
		stand_dir(facing_dir)

func skate_pose_sprite_by_vector(in_vector : Vector2):
	if(in_vector.length() > 0):
		face_to_vector(in_vector)
		var frame : int = 1
		if(facing_dir == direction.up):
			frame = 3
		walk_dir_frame(facing_dir, frame)

func turn_right():
	match(facing_dir):
		direction.right:
			facing_dir = direction.down
		direction.down:
			facing_dir = direction.left
		direction.left:
			facing_dir = direction.up
		direction.up:
			facing_dir = direction.right

func turn_left():
	match(facing_dir):
		direction.right:
			facing_dir = direction.up
		direction.down:
			facing_dir = direction.right
		direction.left:
			facing_dir = direction.down
		direction.up:
			facing_dir = direction.left

#scales the animation speed to a given scaler. base and remainder must add up to 1 for 
#this to work.
func set_animation_scale(base, remainder, scalar, top_speed):
	#scale animation to movement speed
	if(scalar > 1):
		#Base speed of 20%. We ramp to 100% (full speed) using a ratio of 
		#speed/topspeed for the remaining 80%.	
		var baseScale = base
		var velocityScale = scalar / top_speed
		var remainderScale = remainder * velocityScale
		var animationScale = baseScale + remainderScale
		set_speed_scales(animationScale)
	else:
		set_speed_scales(1)

func set_animation_scale_ratio(ratio):
	set_speed_scales(ratio)

#given resource path strings will load those resoruces and set the corresponding spriteframes
func load_and_set_spriteframes(base : String, hat : String, top: String, bottom : String):
	var base_sprite : SpriteFrames = null
	var hat_sprite : SpriteFrames = null
	var top_sprite : SpriteFrames = null
	var bottom_sprite : SpriteFrames = null
	if(base != ""):
		base_sprite = load(base)
	if(hat != ""):
		hat_sprite = load(hat)
	if(top != ""):
		top_sprite = load(top)
	if(bottom != ""):
		bottom_sprite = load(bottom)
	set_spriteframes(base_sprite, hat_sprite, top_sprite, bottom_sprite)

func set_spriteframes_include_null(base, hat, top, bottom):
	_base_sprite.sprite_frames = base
	_hat.sprite_frames = hat
	_top.sprite_frames = top
	_bottom.sprite_frames = bottom
	if(Engine.is_editor_hint()):
		queue_redraw()

func reduce_to_base():
	_hat.visible = false
	_top.visible = false
	_bottom.visible = false

func restore_non_base_sprites():
	_hat.visible = true
	_top.visible = true
	_bottom.visible = true

func set_spriteframes(base, hat, top, bottom, accessory = null):
	if(_base_sprite != null):
		_base_sprite.sprite_frames = base
	if(_accessory != null):
		_accessory.sprite_frames = accessory
	if(_hat != null):
		_hat.sprite_frames = hat
	if(_top != null):
		_top.sprite_frames = top
	if(_bottom != null):
		_bottom.sprite_frames = bottom
	if(Engine.is_editor_hint()):
		queue_redraw()

func show_headphones():
	_headphones.visible = true

func hide_headphones():
	_headphones.visible = false

func set_base_spriteframes(base : SpriteFrames):
	if(_base_sprite != null):
		_base_sprite.sprite_frames = base
		synch_animations()

func get_base_spriteframes() -> SpriteFrames:
	return _base_sprite.sprite_frames

func set_hat_spriteframes(hat):
	if(_hat != null):
		_hat.sprite_frames = hat

func set_top_spriteframes(top):
	if(_top != null):
		_top.sprite_frames = top

func set_bottom_spriteframes(bottom):
	if(_bottom != null):
		_bottom.sprite_frames = bottom

func set_visibility(value : bool):
	_base_sprite.visible = value
	_accessory.visible = value
	_hat.visible = value
	_top.visible = value
	_bottom.visible = value

func start_flashing():
	flashing = true

func stop_flashing():
	flashing = false
	is_visible = true
	set_visibility(is_visible)

# Called when the node enters the scene tree for the first time.
func _ready():
	set_spriteframes(base_spriteframes,
	hat_spriteframes,
	top_spriteframes,
	bottom_spriteframes)
	flashing_timer.one_shot = true
	add_child(flashing_timer)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(flashing && flashing_timer.is_stopped()):
		flashing_timer.start(0.05)
		is_visible = !is_visible
		set_visibility(is_visible)
		
