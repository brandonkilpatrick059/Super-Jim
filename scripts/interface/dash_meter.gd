@tool
extends Control

var fraction_filled = 1.0
var full_bar_pixels = 103.0
var current_bar_pixels = 0.0

var timer : Timer = Timer.new()

var blink_step = 0.05
var blink_step_secs = 0.001
var blink_amount = 0
var blue_bar_color : Color = Color(0,1,1,1)
var going_up = true
var is_blinking = false

func _ready():
	timer.one_shot = true
	add_child(timer)

func start_blinking():
	is_blinking = true
	going_up = true
	timer.start(blink_step_secs)

func stop_blinking():
	is_blinking = false
	blue_bar_color = Color(0,1,1,1)

func _draw():
	var white_bar_width : float = current_bar_pixels
	var blue_bar_width : float = current_bar_pixels * fraction_filled
	draw_rect(Rect2(4.0, 2.0, white_bar_width, 6.0), Color.SLATE_GRAY)
	draw_rect(Rect2(4.0, 2.0, blue_bar_width, 6.0), blue_bar_color)
	#draw_rect(Rect2(4.0, 2.0, 103.0, 6.0), Color.SLATE_GRAY)
	#draw_rect(Rect2(4.0, 2.0, 103.0 * 0.5, 6.0), Color.AQUA)

#where 0 <= n <= 1
func set_fraction_filled(fraction: float):
	fraction_filled = fraction
	queue_redraw()

#where 0 <= n <= 1
func set_fraction_of_full_bar(fraction : float):
	current_bar_pixels = full_bar_pixels * fraction
	queue_redraw()

func _physics_process(delta: float) -> void:
	if(is_blinking && timer.is_stopped()):
		if(going_up):
			if(blink_amount < 1.0):
				blink_amount = blink_amount + blink_step
			else:
				going_up = false
		else:
			if(blink_amount > 0.0):
				blink_amount = blink_amount - blink_step
			else:
				going_up = true
		blue_bar_color = Color(blink_amount,1,1,1)
		timer.start(blink_step_secs)
		

func _process(delta):
	if(Engine.is_editor_hint()):
		queue_redraw()
