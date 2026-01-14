@tool
extends PointLight2D

@export var energy_min : float = 0.0
@export var energy_max : float = 1.0
@export var rate : float = 0.01

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
	energy = energy_max
	brightening = false
	fading_out = true

func _physics_process(delta: float) -> void:
	if(timer.is_stopped()):
		if(brightening):
			if(energy < energy_max):
				energy = energy + rate
			else:
				brightening = false
		else:
			if(energy > energy_min):
				energy = energy - rate
			else:
				brightening = true
				if(fading_out):
					enabled = false
