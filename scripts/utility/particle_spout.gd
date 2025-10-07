@tool
extends Node2D

@export var particle_path : String = ""
@export var seconds_between_particles = 1.0
@export var run_in_editor = false

var timer : Timer = Timer.new()

func _ready():
	timer.one_shot = true
	add_child(timer)
	timer.start(seconds_between_particles)

func _physics_process(delta: float) -> void:
	if(!Engine.is_editor_hint() || (Engine.is_editor_hint() && run_in_editor)):
		if(timer.is_stopped()):
			var particle = load(particle_path)
			var new_particle = particle.instantiate()
			add_child(new_particle)
			new_particle.global_position = global_position
			timer.start(seconds_between_particles)
