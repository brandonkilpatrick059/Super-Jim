extends Node2D

@export var stat : String = ""

@onready var _sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var _mitt : Sprite2D = $mitt
@onready var _num_readout : Label = $num_readout

var sprite_alpha : float = 0.0
var mitt_alpha : float = 0.0
var alpha_fade_step : float = 0.1
var step_secs = 0.006

var sprite_fade_timer : Timer = Timer.new()
var mitt_fade_timer : Timer = Timer.new()

var sprite_faded_in = false
var mitt_faded_in = false
var catching = false

var buff = 0

func _ready() -> void:
	
	_num_readout.visible = false
	_sprite.modulate = Color(1,1,1,0.0)
	_mitt.modulate = Color(1,1,1,0.0)
	sprite_fade_timer.one_shot = true
	add_child(sprite_fade_timer)
	mitt_fade_timer.one_shot = true
	add_child(mitt_fade_timer)

func set_label(txt : String):
	_num_readout.text = txt

func fade_in_sprite():
	sprite_faded_in = true

func fade_out_sprite():
	sprite_faded_in = false

func fade_in_mitt():
	mitt_faded_in = true

func fade_out_mitt():
	mitt_faded_in = false

func catch() -> int:
	catching = true
	var ret = buff
	buff = 0
	return ret

func _physics_process(delta: float) -> void:
	if(mitt_faded_in && sprite_alpha < 1):
		sprite_alpha = sprite_alpha + alpha_fade_step
