extends Node2D

@export var stat : String = ""

@onready var _sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var _mitt : Sprite2D = $mitt
@onready var _num_readout : Label = $num_readout
@onready var _audio_player : AudioStreamPlayer = $AudioStreamPlayer

var stat_particle = preload("res://baseball/stat_particle.tscn")

var alpha_fade_step : float = 0.1
var step_secs = 0.006

var fade_timer : Timer = Timer.new()
var wait_timer : Timer = Timer.new()

var sprite_fading_in = false
var sprite_fading_out = false
var mitt_fading_in = false
var mitt_fading_out = false
var catching = false

var ready_to_catch = false

var buff = 0

func _ready() -> void:
	_num_readout.visible = false
	_sprite.modulate = Color(1,1,1,0.0)
	_mitt.modulate = Color(1,1,1,0.0)
	_sprite.play(stat)
	fade_timer.one_shot = true
	add_child(fade_timer)
	wait_timer.one_shot = true
	add_child(wait_timer)

func throw_stat(stat_num : int):
	if(buff == 0):
		sprite_fading_in = true
		buff = stat_num
	else:
		buff = buff + stat_num
	set_label(str(buff))
	
	var particle = stat_particle.instantiate()
	add_child(particle)
	particle.global_position = global_position
	particle.set_and_fire(stat_num)

func set_label(txt : String):
	_num_readout.text = txt

func fade_in_sprite():
	sprite_fading_out = false
	sprite_fading_in = true

func fade_out_sprite():
	sprite_fading_out = true
	sprite_fading_in = false

func fade_in_mitt():
	mitt_fading_out = false
	mitt_fading_in = true

func is_ready_to_catch():
	return ready_to_catch

func fade_out_mitt():
	mitt_fading_out = true
	mitt_fading_in = false

func handle_fading():
	if(fade_timer.is_stopped()):
		if(sprite_fading_in):
			if(_sprite.modulate.a >= 1.0):
				sprite_fading_in = false
				_num_readout.visible = true
				ready_to_catch = true
			else:
				var current_alpha = _sprite.modulate.a
				var new_alpha = current_alpha + alpha_fade_step
				_sprite.modulate = Color(1.0,1.0,1.0,new_alpha)
		elif(sprite_fading_out):
			if(_sprite.modulate.a <= 0.0):
				sprite_fading_out = false
			else:
				var current_alpha = _sprite.modulate.a
				var new_alpha = current_alpha - alpha_fade_step
				_sprite.modulate = Color(1.0,1.0,1.0,new_alpha)
		if(mitt_fading_in):
			if(_mitt.modulate.a >= 1.0):
				_audio_player.stream = load("res://audio/soundFX/maracca.ogg")
				_audio_player.play()
				fade_out_mitt()
				fade_out_sprite()
			else:
				var current_alpha = _mitt.modulate.a
				var new_alpha = current_alpha + alpha_fade_step
				_mitt.modulate = Color(1.0,1.0,1.0,new_alpha)
		elif(mitt_fading_out):
			if(_mitt.modulate.a <= 0.0):
				sprite_fading_out = false
			else:
				var current_alpha = _mitt.modulate.a
				var new_alpha = current_alpha - alpha_fade_step
				_mitt.modulate = Color(1.0,1.0,1.0,new_alpha)

func catch(wait_secs : float) -> int:
	if(wait_secs > 0.0):
		catching = true
		wait_timer.start(wait_secs)
	else:
		fire_mitt()
	var ret = buff
	ready_to_catch = false
	buff = 0
	return ret

func fire_mitt():
	fade_in_mitt()
	_num_readout.visible = false
	catching = false

func _physics_process(delta: float) -> void:
	handle_fading()
	if(catching && wait_timer.is_stopped()):
		fire_mitt()
