extends Node2D

var active : bool = false

var timer : Timer = Timer.new()
var alpha_step = 0.05
var time_step = 0.006
var fading_in = false

func make_active():
	visible = true
	active = true

func make_inactive():
	active = false

func _ready() -> void:
	timer.one_shot = true
	add_child(timer)
	visible = false

func _physics_process(delta: float) -> void:
	if(active):
		if(timer.is_stopped()):
			if(fading_in):
				if(modulate.a < 1.0):
					var alpha = modulate.a + alpha_step
					modulate = Color(1.0,1.0,1.0,alpha)
				else:
					fading_in = false
			else:
				if(modulate.a > 0.0):
					var alpha = modulate.a - alpha_step
					modulate = Color(1.0,1.0,1.0,alpha)
				else:
					fading_in = true
			timer.start(time_step)
	else:
		visible = false
