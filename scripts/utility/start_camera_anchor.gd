extends RigidBody2D

var timer : Timer = Timer.new()
var step_timer : Timer = Timer.new()
var step_timer_secs = 0.01
@export var wait_to_move_secs = 0

var player_ref = null
var camera_ref = null

var speed = 128

var moving = false

func _ready() -> void:
	timer.one_shot = true
	add_child(timer)
	step_timer.one_shot = true
	add_child(step_timer)
	timer.start(wait_to_move_secs)
	camera_ref = get_tree().get_first_node_in_group("camera")
	player_ref = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	if(not moving):
		if(timer.is_stopped()):
			moving = true
			step_timer.start(step_timer_secs)
	else:
		if(step_timer.is_stopped()):
			var distance = global_position.distance_to(player_ref.global_position)
			if(distance > 8):
				if(distance < 256):
					speed = speed - 2.0
				apply_force(Vector2(0,speed))
			else:
				camera_ref.reparent(player_ref)
				player_ref.connect_camera()
				player_ref.set_control_frozen(false)
				queue_free()
			step_timer.start(step_timer_secs)
