extends Node2D
@onready var _animated_sprite = $AnimatedSprite2D
var random = RandomNumberGenerator.new()
var timer : Timer = Timer.new()
var timer_step = 0.1
var move_vector = Vector2(0,0)
var x_factor = 0
var y_factor = 0

func _ready():
	_animated_sprite.play("default",2)
	timer.one_shot = true
	add_child(timer)
	x_factor = random.randf_range(-2.0,2)
	y_factor = random.randf_range(0.0,2.0)
	move_vector = Vector2(x_factor,y_factor)
	timer.start(timer_step)

func _physics_process(delta: float) -> void:
	if(timer.is_stopped()):
		global_position = global_position + move_vector
		look_at(move_vector)
		if(_animated_sprite.frame == _animated_sprite.sprite_frames.get_frame_count("default")-1):
			queue_free()
