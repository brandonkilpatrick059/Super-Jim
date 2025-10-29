extends Label

var menu_alpha = 0
var menu_alpha_step_size = 0.025
var alpha_step_time_secs = 0.05
var fading_in = false

var wait_to_fade_in_timer : Timer = Timer.new()
@export var wait_secs = 0

var fade_timer : Timer = Timer.new()

func _ready():
	modulate = Color(1,1,1,menu_alpha)
	fade_timer.one_shot = true
	wait_to_fade_in_timer.one_shot = true
	add_child(fade_timer)
	add_child(wait_to_fade_in_timer)
	wait_to_fade_in_timer.start(wait_secs)

func _physics_process(delta: float) -> void:
	if(!fading_in && wait_to_fade_in_timer.is_stopped()):
		fading_in = true
		fade_timer.start(alpha_step_time_secs)
	if(fading_in && fade_timer.is_stopped() && menu_alpha < 1):
		menu_alpha = menu_alpha + menu_alpha_step_size
		modulate = Color(1,1,1,menu_alpha)
		fade_timer.start(alpha_step_time_secs)
