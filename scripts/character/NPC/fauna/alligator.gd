extends RigidBody2D

@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var audio_player : AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var collision :CollisionShape2D = $CollisionShape2D

var chomping = true
var right_facing = true
var charging = false
var telegraphing = false

var can_play_snap = true

var regular_speed = 40
var charging_speed = 180

var speed_scale_regular = 1.0
var speed_scale_charging = 4.0

var timer := Timer.new()

func _ready() -> void:
	chomping = true
	sprite.play("chomp")
	timer.one_shot = true
	add_child(timer)

func _physics_process(delta: float) -> void:
	if(chomping):
		var player_ref = get_tree().get_first_node_in_group("player")
		if(global_position.distance_to(player_ref.global_position) < 256):
			if(global_position.y <= player_ref.global_position.y + 24 &&
			global_position.y >= player_ref.global_position.y - 24):
				if(right_facing && global_position.x < player_ref.global_position.x):
					start_charging()
				elif(!right_facing && global_position.x > player_ref.global_position.x):
					start_charging()
		if(can_play_snap && sprite.frame == 2):
			audio_player.play()
			can_play_snap = false
		elif(sprite.frame != 2):
			can_play_snap = true
		var speed = regular_speed
		if(charging):
			speed = charging_speed
		if(linear_velocity.length() < speed):
			if(right_facing):
				apply_force(Vector2(200,0))
			else:
				apply_force(Vector2(-200,0))

func start_charging():
	charging = true
	sprite.speed_scale = speed_scale_charging

func stop_charging():
	charging = false
	sprite.speed_scale = speed_scale_regular
	linear_velocity = Vector2(0,0)

func _on_body_entered(body: Node) -> void:
	if(charging):
		stop_charging()
		if(body.is_in_group("player")):
			body.reduce_hp()
			right_facing = !right_facing
			sprite.flip_h = !sprite.flip_h
	if(!body.is_in_group("player")):
		right_facing = !right_facing
		sprite.flip_h = !sprite.flip_h
