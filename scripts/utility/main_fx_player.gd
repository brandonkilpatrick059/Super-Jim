extends AudioStreamPlayer

var zero_volume = -60
var fading_out_diagetic_music = false
var fading_out_effects = false

var timer := Timer.new()

var fade_step = 0.5
var time_step = 0.006

var diagetic_music_bus_index = 4
var effects_bus_index = 3

func _ready() -> void:
	timer.one_shot = true
	add_child(timer)

func fade_out_diagetic_music_bus():
	fading_out_diagetic_music = true

func fade_in_diagetic_music_bus():
	fading_out_diagetic_music = false

func fade_out_effects_bus():
	fading_out_effects = true

func fade_in_effects_bus():
	fading_out_effects = false

func handle_fading():
	var effects_vol = AudioServer.get_bus_volume_db(effects_bus_index)
	var d_music_vol = AudioServer.get_bus_volume_db(diagetic_music_bus_index)
	if(fading_out_effects):
		if(effects_vol > zero_volume):
			AudioServer.set_bus_volume_db(effects_bus_index, effects_vol - fade_step)
	else:
		if(effects_vol < 0.0):
			AudioServer.set_bus_volume_db(effects_bus_index, effects_vol + fade_step)
	if(fading_out_diagetic_music):
		if(d_music_vol > zero_volume):
			AudioServer.set_bus_volume_db(diagetic_music_bus_index, d_music_vol - fade_step)
	else:
		if(d_music_vol < 0.0):
			AudioServer.set_bus_volume_db(diagetic_music_bus_index, d_music_vol + fade_step)

func _physics_process(delta: float) -> void:
	if(timer.is_stopped()):
		handle_fading()
		timer.start(time_step)
