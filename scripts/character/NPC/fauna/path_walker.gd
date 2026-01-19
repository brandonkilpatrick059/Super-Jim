extends RigidBody2D

@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var audio_player : AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var collision :CollisionShape2D = $CollisionShape2D

@export var stage_marks : Array[Node] = []

@export var move_dir : String = direction.left
@export var turns_right : bool = true

var speed = 40

var timer := Timer.new()

func _ready() -> void:
	timer.one_shot = true
	add_child(timer)

func turn_right():
	linear_velocity = Vector2(0,0)
	match(move_dir):
		direction.right:
			move_dir = "down"
		direction.left:
			move_dir = "up"
		direction.up:
			move_dir = "right"
		direction.down:
			move_dir = "left"

func turn_left():
	linear_velocity = Vector2(0,0)
	match(move_dir):
		direction.right:
			move_dir = "up"
		direction.left:
			move_dir = "down"
		direction.up:
			move_dir = "left"
		direction.down:
			move_dir = "right"

func _physics_process(delta: float) -> void:
	if(timer.is_stopped()):
		for mark in stage_marks:
			if(global_position.distance_to(mark.global_position) <= 8):
				if(turns_right):
					turn_right()
					timer.start(1)
				else:
					turn_left()
					timer.start(1)
	if(linear_velocity.length() < speed):
		match(move_dir):	
			direction.right:
				sprite.play("walk_right")
				apply_force(Vector2(200,0))
			direction.left:
				sprite.play("walk_left")
				apply_force(Vector2(-200,0))
			direction.up:
				sprite.play("walk_right")
				apply_force(Vector2(0,-200))
			direction.down:
				sprite.play("walk_left")
				apply_force(Vector2(0,200))
