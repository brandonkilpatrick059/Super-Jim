extends RigidBody2D

var timer : Timer = Timer.new()
@export var wait_to_move_secs = 0

var player_ref = null
var camera_ref = null

var speed = 48

var moving = false

func _ready() -> void:
	timer.one_shot = true
	add_child(timer)
	timer.start(wait_to_move_secs)
	camera_ref = get_tree().get_first_node_in_group("camera")
	player_ref = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	if(not moving):
		if(timer.is_stopped()):
			moving = true
	else:
		var distance = global_position.distance_to(player_ref.global_position)
		if(distance > 3):
			if(distance < 256):
				speed = speed - 2.0
			apply_force(Vector2(0,speed))
		else:
			camera_ref.reparent(player_ref)
			player_ref.connect_camera()
			player_ref.set_control_frozen(false)
			queue_free()
