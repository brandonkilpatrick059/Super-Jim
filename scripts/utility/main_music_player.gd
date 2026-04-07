extends AudioStreamPlayer

var current_stream : String = ""

var current_volume = 0
var zero_volume = -60

var timer : Timer = Timer.new()
var fade_step = 3
var fade_step_time = 0.05

var fading_out = false
var fading_in = false
#var start_new_stream_wait_time = 1

var changing_streams = false
#var ready_play_new_stream = false

var skipping_fade_in = false

var current_playback_position : float = 0.0
var paused : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	timer.one_shot = true
	add_child(timer)
	bus = "Music"

func get_stream_name() -> String:
	return current_stream

func change_stream(new_stream: String, skip_fade_in : bool = true):
	#if(current_stream != ""):
	current_volume = volume_db
	changing_streams = true
	fading_out = true
	current_stream = new_stream
	timer.start(fade_step_time)
	skipping_fade_in = skip_fade_in
	#else:
		#current_volume = 0
		#changing_streams = false
		#current_stream = new_stream
		#stream = load(new_stream)
		#play()

func pause():
	if(!paused):
		current_playback_position = get_playback_position()
		stop()
		paused = true

func unpause():
	if(paused):
		if(current_stream != "" &&
		current_playback_position != 0.0):
			play(current_playback_position)
		paused = false

func set_volume(volume : float):
	volume_db = volume

func is_changing_streams():
	return changing_streams

func set_volume_ratio(ratio : float):
	volume_db = (1.0 - ratio) * zero_volume

func attenuate(amount : float):
	if(volume_db + amount > 0):
		volume_db = 0
	else:
		volume_db = amount

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(changing_streams && timer.is_stopped()):
		if(fading_out && volume_db > zero_volume):
			volume_db = volume_db - fade_step
			timer.start(fade_step_time)
		elif(fading_in && volume_db < 0):
			volume_db = volume_db + fade_step
			timer.start(fade_step_time)
		elif(fading_in && volume_db == 0):
			changing_streams = false
			fading_in = false
		elif(volume_db <= zero_volume):
			stop()
			fading_out = false
			if(skipping_fade_in):
				fading_in = false
				changing_streams = false
				skipping_fade_in = false
				volume_db = 0
			else:
				fading_in = true
			if(current_stream != ""):
				stream = load(current_stream)
				play()
				
			
			
