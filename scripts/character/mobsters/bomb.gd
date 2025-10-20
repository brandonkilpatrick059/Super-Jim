extends RigidBody2D

@onready var _animatedSprite = $AnimatedSprite2D
var explosion = preload("res://effects/explosion.tscn")
var blu_shrapnel = preload("res://entities/characters/NPC/mobsters/blu_shrapnel.tscn")
var red_shrapnel = preload("res://entities/characters/NPC/mobsters/red_shrapnel.tscn")

@export var team = "blu"

var sound_player := AudioStreamPlayer2D.new()

var trajectory : Vector2 = Vector2(0,0)
var travel_speed = 64

var random : RandomNumberGenerator = RandomNumberGenerator.new()

var source_obj : Node2D

func set_source_obj(obj : Node2D):
	source_obj = obj

func _ready() -> void:
	sound_player.max_distance = 500
	sound_player.attenuation = 2
	sound_player.bus = "Effects"
	add_child(sound_player)
	self.add_to_group(team)
	match(team):
		"red":
			_animatedSprite.modulate = Color(1,0,0)
		"blu":
			_animatedSprite.modulate = Color(0,0,1)

func set_trajectory(vector : Vector2):
	trajectory = vector

func explode():
	var new_explosion = explosion.instantiate()
	get_parent().call_deferred("add_child", new_explosion)
	new_explosion.add_to_group(team)
	new_explosion.position = position
	
	var iter = 0
	var rot = random.randf_range(0,360)
	while(iter < 4):
		var new_bullet
		if(team == "red"):
			new_bullet = red_shrapnel.instantiate()
		else: if(team == "blu"):
			new_bullet = blu_shrapnel.instantiate()
		new_bullet.set_source_obj(source_obj)
		get_parent().add_child(new_bullet)
		rot = rot + 90
		new_bullet.rotation_degrees = rot
		new_bullet.position = position
		new_bullet.apply_velocity()
		iter = iter + 1
	queue_free()

func _physics_process(delta: float) -> void:
	var frames : SpriteFrames = _animatedSprite.sprite_frames
	if(_animatedSprite.frame == frames.get_frame_count("default") - 1):
		explode()
	else:
		linear_velocity = trajectory * travel_speed
