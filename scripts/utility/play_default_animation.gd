@tool

extends AnimatedSprite2D

@export var wait_offset : float = 0
@export var not_prunable = false

var timer : Timer = Timer.new()

var random = RandomNumberGenerator.new()

var is_playing : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	if(!not_prunable):
		add_to_group("prunable")
	timer.one_shot = true
	add_child(timer)
	timer.start(random.randf_range(0,wait_offset))

func _process(delta : float) -> void:
	if(is_playing):
		pass
	elif(wait_offset == 0 || timer.is_stopped()):
			var frames : SpriteFrames = sprite_frames
			var animation_name = "default"
			if(frames.has_animation(animation_name)):
				play(animation_name)
				is_playing = true
