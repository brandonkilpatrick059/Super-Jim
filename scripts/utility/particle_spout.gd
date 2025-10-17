@tool
extends Node2D

@export var particle_path : String = ""
@export var min_seconds_between_particles = 1.0
@export var max_seconds_between_particles = 1.0
@export var run_in_editor = false

var timer : Timer = Timer.new()
var particle = null
var player_ref : Node2D = null
var distance_to_stop_x = 400
var distance_to_stop_y = 248

var random : RandomNumberGenerator = RandomNumberGenerator.new()

func get_player_ref():
	if(!player_ref):
		player_ref = get_tree().get_first_node_in_group("camera")
	return player_ref

func _ready():
	timer.one_shot = true
	add_child(timer)
	timer.start(random.randf_range(0,1))
	particle = load(particle_path)

func _physics_process(delta: float) -> void:
	if(!Engine.is_editor_hint() || (Engine.is_editor_hint() && run_in_editor)):
		var run_spout = true
		if(!Engine.is_editor_hint()):
			get_player_ref()
			var pos_y : float = global_position.y - player_ref.global_position.y
			var pos_x : float = global_position.x - player_ref.global_position.x
			if(abs(pos_y) > distance_to_stop_y ||
			abs(pos_x) > distance_to_stop_x ):
				run_spout = false

		if(run_spout && timer.is_stopped()):
			var new_particle = particle.instantiate()
			add_child(new_particle)
			new_particle.global_position = global_position
			var time = random.randf_range(min_seconds_between_particles,max_seconds_between_particles)
			timer.start(time)
