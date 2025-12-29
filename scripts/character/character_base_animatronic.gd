#used by npcs which do not use the typical character_base
#generally for mostly stationary npcs with unique
#shapes and animation patterns where animation is
#controlled by bespoke scripts
@tool
extends Node2D
@onready var _base_sprite :AnimatedSprite2D = $base_sprite
@export var base_spriteframes : SpriteFrames = null
var is_visible = true

func get_base_current_animation():
	return _base_sprite.get_animation()

func get_base_current_frame():
	return _base_sprite.frame

func get_offset() -> Vector2:
	return _base_sprite.offset

func adjust_offset(new_offset: Vector2):
	_base_sprite.offset = new_offset

func get_base_animation_framecount(animation_name: String = ""):
	var base_animation_framecount
	if(animation_name == ""):
		base_animation_framecount = _base_sprite.sprite_frames.get_frame_count(get_base_current_animation())
	else:
		base_animation_framecount = _base_sprite.sprite_frames.get_frame_count(animation_name)
	return base_animation_framecount

func play_animation(animation: String):
	if(_base_sprite.sprite_frames != null):
		_base_sprite.play(animation)

func set_speed_scales(scale):
	if(_base_sprite.sprite_frames != null):
		_base_sprite.set_speed_scale(scale)

func synch_animations():
	_base_sprite.frame = 0

func set_all_materials(material):
	if(_base_sprite.sprite_frames != null):
		_base_sprite.set_material(material)

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
func load_and_set_spriteframes(base : String):
	var base_sprite : SpriteFrames = null
	if(base != ""):
		base_sprite = load(base)
	set_spriteframes(base_sprite)

func set_spriteframes_include_null(base):
	_base_sprite.sprite_frames = base
	if(Engine.is_editor_hint()):
		queue_redraw()

func set_spriteframes(base):
	if(_base_sprite != null):
		_base_sprite.sprite_frames = base
	if(Engine.is_editor_hint()):
		queue_redraw()

func set_visibility(value : bool):
	_base_sprite.visible = value

# Called when the node enters the scene tree for the first time.
func _ready():
	set_spriteframes(base_spriteframes)
