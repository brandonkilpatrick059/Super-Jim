class_name StatParticle
extends Node2D

@onready var label : Label = $Label

var timer = Timer.new()
var fade_step_secs = 0.1
var fade_wait = 5.0
var text_alpha = 1.0
var alpha_fade_step = 0.05

var transform_step =1

var fired = false
var is_buff = false

func _ready():
	timer.one_shot = true
	visible = false

func set_and_fire(num : int):
	if(num > 0):
		label.text = str("+",num)
	else:
		label.text = str(num)
		
	if(num < 0):
		var red = Color (1.0,0.0,0.0,1.0)
		label.modulate = red
	else:
		is_buff = true
		var green = Color (0.0,1.0,0.0,1.0)
		label.modulate = green
	visible = true
	fired = true
	timer.start(fade_step_secs)

func _physics_process(delta: float) -> void:
	if(fired && timer.is_stopped()):
		if(fade_wait > 0):
			fade_wait = fade_wait - fade_step_secs
		else:
			if(text_alpha > 0):
				text_alpha = text_alpha - alpha_fade_step
				if(is_buff):
					var green = Color (0.0,1.0,0.0,text_alpha)
					label.modulate = green
				else:
					var red = Color (1.0,0.0,0.0,text_alpha)
					label.modulate = red
			if(text_alpha <=0):
				queue_free()
		global_position.y = global_position.y - transform_step
		timer.start(fade_step_secs)
