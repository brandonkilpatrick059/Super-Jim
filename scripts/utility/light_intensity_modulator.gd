@tool
extends PointLight2D

@export var energy_min : float = 0.0
@export var energy_max : float = 1.0
@export var rate : float = 0.01

@export var fade_out_and_queue_free : bool = false

@export var spin_clockwise : bool = false
@export var spin_speed : float = 0.0

var step : float = 0.006

var timer := Timer.new()

var brightening = true
var fading_out = false

func _ready() -> void:
	timer.one_shot = true
	add_child(timer)
	energy = energy_min

func fade_in():
	energy = 0.0
	brightening = true
	enabled = true

func fade_out():
	brightening = false
	fading_out = true

func _physics_process(delta: float) -> void:
	if(timer.is_stopped()):
		if(spin_clockwise):
			rotation_degrees = rotation_degrees + spin_speed
		if(brightening):
			if(energy < energy_max):
				energy = energy + rate
			else:
				brightening = false
		else:
			if(fading_out):
				if(energy > 0.0):
					energy = energy - rate
				else:
					enabled = false
					fading_out = false
					energy = 0.0
			else:
				if(energy > energy_min):
					energy = energy - rate
				else:
					if(!fade_out_and_queue_free):
						brightening = true
					else:
						queue_free()
