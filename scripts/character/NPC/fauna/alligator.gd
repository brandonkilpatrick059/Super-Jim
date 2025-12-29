extends RigidBody2D

@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var audio_player : AudioStreamPlayer2D = $AudioStreamPlayer2D

var chomping = true
var right_facing = true
var charging = false
var telegraphing = false

var can_play_snap = true

var regular_speed = 100
var charging_speed = 200

var speed_scale_regular = 1.0
var speed_scale_charging = 2.0

var timer := Timer.new()

func _ready() -> void:
	chomping = true
	sprite.play("chomp")
	timer.one_shot = true
	add_child(timer)

func _physics_process(delta: float) -> void:
	if(chomping):
		if(can_play_snap && sprite.frame == 2):
			audio_player.play()
			can_play_snap = false
		elif(sprite.frame != 2):
			can_play_snap = true
		
		if(linear_velocity.length() < 40):
			if(right_facing):
				apply_force(Vector2(regular_speed,0))
			else:
				apply_force(Vector2(-regular_speed,0))

func _on_body_entered(body: Node) -> void:
	if(body.is_in_group("player")):
		body.reduce_hp()
	if(right_facing):
		right_facing = false
		sprite.flip_h = true
	else:
		right_facing = true
		sprite.flip_h = false
