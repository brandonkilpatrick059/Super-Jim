extends Area2D

@onready var sprite :AnimatedSprite2D = $AnimatedSprite2D

var timer := Timer.new()

var expanding = true

var scale_factor : float = 1.0
var current_frame : int = 0

var drift_vector : Vector2 = Vector2(0,0)

@onready var audio_player : AudioStreamPlayer2D = $AudioStreamPlayer2D
 
func enable_collision_shapes():
	var mob_collision = $CollisionShape2D
	var sight_collision = $sightline_blocker/CollisionShape2D
	mob_collision.disabled = false
	sight_collision.disabled = false 

func disable_collision_shapes():
	var mob_collision = $CollisionShape2D
	var sight_collision = $sightline_blocker/CollisionShape2D
	mob_collision.disabled = true
	sight_collision.disabled = true

func scale_collision_shapes(scale : float):
	var mob_collision : CollisionShape2D  = $CollisionShape2D
	var sight_collision : CollisionShape2D = $sightline_blocker/CollisionShape2D
	mob_collision.scale = Vector2(scale,scale)
	sight_collision.scale = Vector2(scale,scale)

func _ready() -> void:
	disable_collision_shapes()
	timer.one_shot = true
	add_child(timer)
	sprite.play("expand")
	drift_vector = Vector2(randf_range(-10,10),randf_range(-10,10))
	get_parent().linear_velocity = drift_vector
	audio_player.stream = load("res://audio/soundFX/smoke_bomb_smoke.wav")
	audio_player.play()

func _on_body_entered(body: Node) -> void:
	if(body.is_in_group("mobster")):
		if(body != null && 
		body.is_not_dead() &&
		 body.get_state_name() != "investigate"):
			body.transition_ai_state_machine("investigate")

func animation_finished():
	if(sprite.sprite_frames.get_frame_count(sprite.animation)-1 == sprite.frame):
		return true
	else:
		return false

func _physics_process(delta: float) -> void:
	if(animation_finished() && expanding):
		expanding = false
		sprite.play("retract")
		enable_collision_shapes()
	elif(animation_finished() && !expanding):
		get_parent().queue_free()
	elif(!expanding):
		if(current_frame != sprite.frame):
			audio_player.volume_db = audio_player.volume_db - 12
			var scaler : float = (float(sprite.frame)/float(sprite.sprite_frames.get_frame_count(sprite.animation)))
			scale_factor = scale_factor - scaler
			if(scale_factor < 0.0):
				scale_factor = 0.0
			scale_collision_shapes(scale_factor)
			current_frame = sprite.frame
			
		
