@tool
extends RigidBody2D

@export var drift_speed_x_min = 1.0
@export var drift_speed_x_max = 1.0
@export var drift_speed_y_min = 1.0
@export var drift_speed_y_max = 1.0
@export var spin_speed_min = 1.0
@export var spin_speed_max = 1.0
@export var speed_factor_min = 1.0
@export var speed_factor_max = 1.0

@onready var particle_sprite : AnimatedSprite2D = $AnimatedSprite2D

var drift_vector : Vector2 = Vector2(0,0)
var spin_velocity = 0
var random : RandomNumberGenerator = RandomNumberGenerator.new()
var timer : Timer = Timer.new()
var speed_factor = 1

var started = false

func _ready() -> void:
	particle_sprite.play("default")
	started = true
	drift_vector = Vector2(random.randf_range(drift_speed_x_min,drift_speed_x_max),random.randf_range(drift_speed_y_min,drift_speed_y_max))
	spin_velocity = random.randf_range(spin_speed_min,spin_speed_max)
	speed_factor = random.randf_range(speed_factor_min,speed_factor_max)
	particle_sprite.play("default",speed_factor)

func _physics_process(delta: float) -> void:
	if(particle_sprite.frame == particle_sprite.sprite_frames.get_frame_count("default")-1):
		queue_free()
	else:
		apply_force(drift_vector)
		apply_torque(spin_velocity)
		started = true
		
