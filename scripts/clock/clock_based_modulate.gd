extends Sprite2D

var time_keeper = null
var fade_level = 0.0 
var fade_time = 3.0
var timer_fade := Timer.new()
var fade_quotient = 0.05
var time_between_fades_secs = 0.05
var fading = false
var paused = false

var num_steps = 60
var step_r = 0.0
var step_g = 0.0
var step_b = 0.0
var step_a = 0.0

var key_a : int
var key_b : int

var interpolation_gradient = Gradient.new()
var fade_out_interpolation = Gradient.new()

@export var keys : Array[Color] = [] #must have 24 keys

var timer :=Timer.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	time_keeper = get_tree().get_nodes_in_group("time_keeper")[0]
	modulate = Color(1,1,1,0.0)
	timer.one_shot = true
	add_child(timer)
	key_a = time_keeper.get_hour()
	key_b = key_a

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	num_steps = time_keeper.get_hour_length_seconds()
	if(key_b != time_keeper.get_hour()):
		key_a = key_b
		key_b = time_keeper.get_hour()
		modulate = keys[key_a]
		var destination_color = keys[key_b]
		step_r = (keys[key_b].r - keys[key_a].r)/num_steps
		step_g = (keys[key_b].g - keys[key_a].g)/num_steps
		step_b = (keys[key_b].b - keys[key_a].b)/num_steps
		step_a = (keys[key_b].a - keys[key_a].a)/num_steps
	else:
		if(timer.is_stopped()):
			modulate = modulate + Color(step_r,step_g,step_b,step_a)
			timer.start(1)
