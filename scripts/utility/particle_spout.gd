@tool
extends Node2D

@export var particle_path : String = ""
@export var seconds_between_particles = 1.0
@export var run_in_editor = false

var timer : Timer = Timer.new()
var particle = null
var player_ref : Node2D = null
var distance_to_stop = 700

func get_player_ref():
	if(!player_ref):
		player_ref = get_tree().get_first_node_in_group("player")
	return player_ref

func _ready():
	timer.one_shot = true
	add_child(timer)
	timer.start(seconds_between_particles)
	particle = load(particle_path)

func _physics_process(delta: float) -> void:
	if(!Engine.is_editor_hint() || (Engine.is_editor_hint() && run_in_editor)):
		var run_spout = true
		if(!Engine.is_editor_hint()):
			if(global_position.distance_to(get_player_ref().global_position) > distance_to_stop):
				run_spout = false
		if(run_spout && timer.is_stopped()):
			var new_particle = particle.instantiate()
			add_child(new_particle)
			new_particle.global_position = global_position
			timer.start(seconds_between_particles)
