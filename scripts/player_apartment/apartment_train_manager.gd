extends Node2D

@onready var bright_window : Sprite2D = $bright_window
@onready var bright_window2 : Sprite2D = $bright_window2
@onready var dark_window : Sprite2D = $dark_window
@onready var dark_window2 : Sprite2D = $dark_window2

@export var daytime_lights : Array[Node2D] = []
@export var nighttime_lights : Array[Node2D] = []

@onready var sensor : Node2D = $apartment_train_sensor
@onready var train_sound : AudioStreamPlayer2D = $train_through_wall

var dark_windows : Array[Node2D] = []
var bright_windows : Array[Node2D] = []

var train_ref : Node2D = null
var player_ref : Node2D = null

var proximity_range : float = 300.0

var timer := Timer.new()
var train_duration_secs : float = 4.5
var max_volume : float = 0.0
var min_volume : float = -80.0
var vol_adjust_timer := Timer.new()
var shake_adjust_timer := Timer.new()
var shake_adjust_step_secs = 0.0

var flashing_night_time_lights = false
var has_flashed = false
var light_flashes = 0
var window_flash_timer := Timer.new()
var dimming : bool = false
var daytime_light_return_intensity : float = 0.0

var camera_shake_max : int = 4
var camera_shake_magnitude = 0

func _ready() -> void:
	timer.one_shot = true
	add_child(timer)
	vol_adjust_timer.one_shot = true
	add_child(vol_adjust_timer)
	shake_adjust_timer.one_shot = true
	add_child(shake_adjust_timer)
	window_flash_timer.one_shot = true
	add_child(window_flash_timer)
	daytime_light_return_intensity = daytime_lights[0].get_child(0).energy
	dark_windows = [dark_window,dark_window2]
	bright_windows = [bright_window,bright_window2]
	for light in nighttime_lights:
		light.get_child(0).energy = 0.0

func flash_daytime_lights():
	dimming = true
	light_flashes = 2
	flashing_night_time_lights = false

func flash_nighttime_lights():
	dimming = false
	light_flashes = 2
	flashing_night_time_lights = true

func update_flash_daytime_lights():
	if(!flashing_night_time_lights && light_flashes > 0):
		var energy_step :float = 0.02
		if(window_flash_timer.is_stopped()):
			for light in daytime_lights:
				var energy : float = light.get_child(0).energy
				if(dimming && energy > 0.0):
					light.get_child(0).energy = energy - energy_step
				elif(dimming && energy <= 0.0):
					dimming = false
				elif(!dimming && energy < daytime_light_return_intensity):
					light.get_child(0).energy = energy + energy_step
				elif(!dimming && energy >= daytime_light_return_intensity):
					light.get_child(0).energy = daytime_light_return_intensity
					light_flashes = light_flashes - 1
					dimming = true
				for window in dark_windows:
					var alpha = 1.0 - (energy / daytime_light_return_intensity)
					window.modulate = Color(1.0,1.0,1.0,alpha)
			window_flash_timer.start(0.006)

func update_flash_nighttime_lights():
	var nighttime_light_intensity : float = 0.6
	if(flashing_night_time_lights && light_flashes > 0):
		var energy_step :float = 0.02
		if(window_flash_timer.is_stopped()):
			for light in nighttime_lights:
				var energy : float = light.get_child(0).energy
				if(dimming && energy > 0.0):
					light.get_child(0).energy = energy - energy_step
				elif(dimming && energy <= 0.0):
					dimming = false
					light_flashes = light_flashes - 1
				elif(!dimming && energy < nighttime_light_intensity):
					light.get_child(0).energy = energy + energy_step
				elif(!dimming && energy >= nighttime_light_intensity):
					light.get_child(0).energy = nighttime_light_intensity
					dimming = true
				for window in bright_windows:
					var alpha = energy / nighttime_light_intensity
					window.modulate = Color(1.0,1.0,1.0,alpha)
			window_flash_timer.start(0.006)

func update_train_sound():
	if(vol_adjust_timer.is_stopped()):
		if(timer.is_stopped() && 
		train_sound.volume_db > min_volume):
			train_sound.volume_db = train_sound.volume_db - 0.5
		elif(!timer.is_stopped() &&
		train_sound.volume_db < max_volume):
			train_sound.volume_db = train_sound.volume_db + 0.5
		if(!timer.is_stopped() && 
		train_sound.volume_db >= max_volume &&
		not has_flashed):
			if(daytime_lights[0].get_child(0).enabled):
				flash_daytime_lights()
			else:
				flash_nighttime_lights()
			has_flashed = true
		vol_adjust_timer.start(0.006)

func update_camera_shake():
	if(shake_adjust_timer.is_stopped()):
		if(timer.is_stopped() && 
		camera_shake_magnitude > 0.0):
			camera_shake_magnitude = camera_shake_magnitude - 1
		elif(!timer.is_stopped() &&
		camera_shake_magnitude < camera_shake_max):
			camera_shake_magnitude = camera_shake_magnitude + 1
		shake_adjust_timer.start(shake_adjust_step_secs)

func update_proximity():
	if(timer.is_stopped()):
		var distance : float = sensor.global_position.distance_to(train_ref.global_position)
		if(distance < proximity_range):
			timer.start(train_duration_secs)
			has_flashed = false

func _physics_process(delta: float) -> void:
	if(train_ref == null):
		train_ref = get_tree().get_first_node_in_group("commuter_train")
		player_ref = get_tree().get_first_node_in_group("player")
		shake_adjust_step_secs = 0.25
	update_proximity()
	update_train_sound()
	#update_camera_shake()
	if(!timer.is_stopped()):
		player_ref.shake_camera(2)
	update_flash_daytime_lights()
	update_flash_nighttime_lights()
	
